const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const dotenv = require('dotenv');
const express = require('express');
const multer = require('multer');
const sharp = require('sharp');
const { createClient } = require('@supabase/supabase-js');

/**
 * Supported deployment environments for this tool.
 */
const ENVIRONMENT_DEFINITIONS = Object.freeze({
  development: {
    label: 'development',
    color: 'green',
    fileName: '.env.development',
  },
  staging: {
    label: 'staging',
    color: 'orange',
    fileName: '.env.staging',
  },
  production: {
    label: 'production',
    color: 'red',
    fileName: '.env.production',
  },
});

/**
 * Default page size for template listing.
 */
const DEFAULT_PAGE_SIZE = 24;

/**
 * Maximum allowed page size.
 */
const MAX_PAGE_SIZE = 60;

/**
 * Signed URL expiration time in seconds.
 */
const SIGNED_URL_EXPIRES_IN_SECONDS = 60 * 60;

/**
 * Maximum upload size for template source files.
 */
const MAX_UPLOAD_BYTES = 20 * 1024 * 1024;

/**
 * In-memory cache of Supabase clients by environment.
 */
const supabaseClientCache = new Map();

/**
 * In-memory environment config map loaded during process startup.
 */
const environmentConfigs = loadEnvironmentConfigs(__dirname);

const app = express();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_UPLOAD_BYTES,
  },
});

app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

/**
 * Returns the static metadata for the three known environments.
 */
app.get('/api/environments', (_request, response) => {
  const environments = Object.values(ENVIRONMENT_DEFINITIONS).map(
    (definition) => {
      const config = environmentConfigs[definition.label];
      return {
        name: definition.label,
        label: definition.label,
        color: definition.color,
        configured: config.configured,
      };
    },
  );

  response.json({ environments });
});

/**
 * Returns one paginated page of meme templates and signed image URLs.
 */
app.get('/api/templates', async (request, response, next) => {
  try {
    const environmentName = resolveEnvironmentName(request);
    const config = getEnvironmentConfig(environmentName);
    const supabase = getSupabaseClient(environmentName);

    const search = normalizeSearch(request.query.search);
    const limit = resolvePageSize(request.query.limit);
    const cursorCreatedAt = readOptionalString(request.query.cursorCreatedAt);
    const cursorId = readOptionalString(request.query.cursorId);

    const { data: rpcPage, error: rpcError } = await supabase.rpc(
      'meme_templates_list',
      {
        p_search: search,
        p_limit: limit,
        p_cursor_created_at: cursorCreatedAt,
        p_cursor_id: cursorId,
      },
    );

    if (rpcError) {
      throw new HttpError(500, `Failed to list meme templates: ${rpcError.message}`);
    }

    const page = normalizeRpcPage(rpcPage);
    const templateIds = page.items
      .map((item) => item.id)
      .filter((id) => typeof id === 'string');

    const detailsById = await loadTemplateDetailsById(supabase, templateIds);
    const signedUrlByPath = await loadSignedUrlsByPath(
      supabase,
      config.storageBucket,
      page.items.map((item) => item.image_path),
    );

    const items = page.items.map((item) => {
      const details = detailsById.get(item.id) ?? null;
      return {
        id: item.id,
        imagePath: item.image_path,
        aspectRatio: Number(item.aspect_ratio),
        createdAt: item.created_at,
        updatedAt: details?.updated_at ?? null,
        tags: Array.isArray(details?.tags) ? details.tags : [],
        isActive: typeof details?.is_active === 'boolean' ? details.is_active : true,
        signedUrl: signedUrlByPath.get(item.image_path) ?? null,
      };
    });

    response.json({
      items,
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * Updates mutable meme-template metadata (currently only tags).
 */
app.patch('/api/templates/:templateId', async (request, response, next) => {
  try {
    const environmentName = resolveEnvironmentName(request);
    const supabase = getSupabaseClient(environmentName);
    const templateId = String(request.params.templateId ?? '').trim();

    if (!templateId) {
      throw new HttpError(400, 'Template id is required.');
    }

    const tags = normalizeTags(request.body?.tags);
    const { data, error } = await supabase
      .from('meme_templates')
      .update({ tags })
      .eq('id', templateId)
      .select('id,tags,updated_at')
      .single();

    if (error) {
      throw new HttpError(500, `Failed to update meme template: ${error.message}`);
    }

    response.json({
      id: data.id,
      tags: Array.isArray(data.tags) ? data.tags : [],
      updatedAt: data.updated_at,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * Uploads one or many new meme templates, converting source images to PNG.
 */
app.post('/api/templates', upload.array('files'), async (request, response, next) => {
  try {
    const environmentName = resolveEnvironmentName(request);
    const config = getEnvironmentConfig(environmentName);
    const supabase = getSupabaseClient(environmentName);
    const fallbackTags = normalizeTags(request.body?.tags);
    const tagsByIndex = parseTagsByIndex(request.body?.tagsByIndex);
    const files = Array.isArray(request.files) ? request.files : [];

    if (files.length === 0) {
      throw new HttpError(400, 'At least one image file is required.');
    }

    /** @type {Array<any>} */
    const created = [];
    /** @type {Array<{ fileName: string, message: string }>} */
    const failed = [];

    for (const [fileIndex, file] of files.entries()) {
      try {
        const fileTags = resolveUploadTagsForFile({
          tagsByIndex,
          fileIndex,
          fallbackTags,
        });

        const createdItem = await createTemplateFromUpload({
          supabase,
          bucket: config.storageBucket,
          sourceBuffer: file.buffer,
          tags: fileTags,
        });
        created.push(createdItem);
      } catch (error) {
        failed.push({
          fileName: file.originalname || 'unknown',
          message: error instanceof Error ? error.message : 'Unknown upload error.',
        });
      }
    }

    if (created.length === 0) {
      throw new HttpError(
        400,
        `Failed to upload all files. First error: ${failed[0]?.message ?? 'Unknown error.'}`,
      );
    }

    response.status(failed.length === 0 ? 201 : 200).json({
      created,
      failed,
      totalReceived: files.length,
      convertedCount: created.length,
      failedCount: failed.length,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * Returns index.html for all unknown non-API routes.
 */
app.get(/^(?!\/api\/).*/, (request, response) => {
  response.sendFile(path.join(__dirname, 'public', 'index.html'));
});

/**
 * Global API error handler.
 */
app.use((error, _request, response, _next) => {
  if (error instanceof multer.MulterError) {
    response.status(400).json({
      message: `Upload error: ${error.message}`,
    });
    return;
  }

  if (error instanceof HttpError) {
    response.status(error.status).json({ message: error.message });
    return;
  }

  if (error instanceof Error) {
    response.status(500).json({ message: error.message });
    return;
  }

  response.status(500).json({ message: 'Unknown server error.' });
});

const port = Number(process.env.PORT ?? 5179);
app.listen(port, () => {
  const summary = Object.values(environmentConfigs)
    .map((config) => `${config.name}:${config.configured ? 'configured' : 'missing'}`)
    .join(', ');
  console.log(`Memuno tools running at http://localhost:${port}`);
  console.log(`Environment files loaded: ${summary}`);
});

/**
 * Loads all supported environment files into memory.
 *
 * @param {string} baseDirectory - Absolute base directory for file lookup.
 * @returns {Record<string, LoadedEnvironmentConfig>}
 */
function loadEnvironmentConfigs(baseDirectory) {
  /** @type {Record<string, LoadedEnvironmentConfig>} */
  const configs = {};

  for (const definition of Object.values(ENVIRONMENT_DEFINITIONS)) {
    const fullPath = path.join(baseDirectory, definition.fileName);
    const parsed = readDotEnvFile(fullPath);

    const supabaseUrl = sanitizeSecretValue(parsed.SUPABASE_URL);
    const supabaseSecretKey = sanitizeSecretValue(parsed.SUPABASE_SECRET_KEY);
    const storageBucket =
      sanitizeSecretValue(parsed.SUPABASE_STORAGE_BUCKET) || 'meme_templates';

    configs[definition.label] = {
      name: definition.label,
      fileName: definition.fileName,
      color: definition.color,
      supabaseUrl,
      supabaseSecretKey,
      storageBucket,
      configured: Boolean(supabaseUrl && supabaseSecretKey),
    };
  }

  return configs;
}

/**
 * Reads and parses one dotenv file.
 *
 * @param {string} absolutePath - Dotenv file path.
 * @returns {Record<string, string>}
 */
function readDotEnvFile(absolutePath) {
  if (!fs.existsSync(absolutePath)) {
    return {};
  }

  const fileContent = fs.readFileSync(absolutePath, 'utf8');
  return dotenv.parse(fileContent);
}

/**
 * Returns a cached Supabase client for an environment.
 *
 * @param {string} environmentName - Environment key.
 * @returns {import('@supabase/supabase-js').SupabaseClient}
 */
function getSupabaseClient(environmentName) {
  if (supabaseClientCache.has(environmentName)) {
    return supabaseClientCache.get(environmentName);
  }

  const config = getEnvironmentConfig(environmentName);
  const client = createClient(config.supabaseUrl, config.supabaseSecretKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  supabaseClientCache.set(environmentName, client);
  return client;
}

/**
 * Returns a single loaded environment config.
 *
 * @param {string} environmentName - Environment key.
 * @returns {LoadedEnvironmentConfig}
 */
function getEnvironmentConfig(environmentName) {
  const config = environmentConfigs[environmentName];
  if (!config) {
    throw new HttpError(400, `Unknown environment "${environmentName}".`);
  }
  if (!config.configured) {
    throw new HttpError(
      400,
      `Environment "${environmentName}" is not configured. Set SUPABASE_URL and SUPABASE_SECRET_KEY in ${config.fileName}.`,
    );
  }
  return config;
}

/**
 * Resolves the environment name from query or request body.
 *
 * @param {import('express').Request} request - Incoming request.
 * @returns {string}
 */
function resolveEnvironmentName(request) {
  const fromQuery = readOptionalString(request.query.environment);
  const fromBody = readOptionalString(request.body?.environment);
  const environmentName = fromQuery ?? fromBody ?? 'development';

  if (!Object.prototype.hasOwnProperty.call(environmentConfigs, environmentName)) {
    throw new HttpError(400, `Unknown environment "${environmentName}".`);
  }

  return environmentName;
}

/**
 * Resolves page size with sane defaults and limits.
 *
 * @param {unknown} value - Query string value.
 * @returns {number}
 */
function resolvePageSize(value) {
  const numeric = Number.parseInt(String(value ?? ''), 10);
  if (Number.isNaN(numeric)) {
    return DEFAULT_PAGE_SIZE;
  }
  return Math.min(Math.max(numeric, 1), MAX_PAGE_SIZE);
}

/**
 * Normalizes optional search input.
 *
 * @param {unknown} value - Query value.
 * @returns {string | null}
 */
function normalizeSearch(value) {
  const stringValue = readOptionalString(value);
  if (!stringValue) {
    return null;
  }
  return stringValue;
}

/**
 * Converts request tag input into normalized tag array.
 *
 * @param {unknown} rawValue - Body field value.
 * @returns {string[]}
 */
function normalizeTags(rawValue) {
  const tagCandidates = [];

  if (Array.isArray(rawValue)) {
    for (const value of rawValue) {
      if (typeof value === 'string') {
        tagCandidates.push(...splitTagString(value));
      }
    }
  } else if (typeof rawValue === 'string') {
    tagCandidates.push(...splitTagString(rawValue));
  } else if (rawValue != null) {
    tagCandidates.push(...splitTagString(String(rawValue)));
  }

  const uniqueByLowercase = new Map();
  for (const candidate of tagCandidates) {
    const normalized = candidate.trim();
    if (!normalized) {
      continue;
    }

    const dedupeKey = normalized.toLowerCase();
    if (!uniqueByLowercase.has(dedupeKey)) {
      uniqueByLowercase.set(dedupeKey, normalized);
    }
  }

  return Array.from(uniqueByLowercase.values());
}

/**
 * Parses one optional JSON array with per-file tag payloads.
 *
 * Each entry in the outer array maps to one uploaded file by index.
 * Every entry can be either a comma-separated string or an array of strings.
 *
 * @param {unknown} rawValue - Raw multipart field value.
 * @returns {string[][]}
 */
function parseTagsByIndex(rawValue) {
  const serialized = readMultipartFieldString(rawValue);
  if (!serialized) {
    return [];
  }

  let parsed;
  try {
    parsed = JSON.parse(serialized);
  } catch (_error) {
    throw new HttpError(400, 'tagsByIndex must be valid JSON.');
  }

  if (!Array.isArray(parsed)) {
    throw new HttpError(400, 'tagsByIndex must be a JSON array.');
  }

  return parsed.map((entry) => normalizeTags(entry));
}

/**
 * Returns one optional text value from a multipart field.
 *
 * @param {unknown} rawValue - Raw multipart value.
 * @returns {string | null}
 */
function readMultipartFieldString(rawValue) {
  if (typeof rawValue === 'string') {
    return rawValue;
  }

  if (Array.isArray(rawValue)) {
    for (const candidate of rawValue) {
      if (typeof candidate === 'string') {
        return candidate;
      }
    }
  }

  return null;
}

/**
 * Resolves final upload tags for one file.
 *
 * @param {{ tagsByIndex: string[][], fileIndex: number, fallbackTags: string[] }} params - Resolve parameters.
 * @returns {string[]}
 */
function resolveUploadTagsForFile({ tagsByIndex, fileIndex, fallbackTags }) {
  if (tagsByIndex.length > 0) {
    const tagsForIndex = tagsByIndex[fileIndex];
    return Array.isArray(tagsForIndex) ? tagsForIndex : [];
  }

  return fallbackTags;
}

/**
 * Splits a tag field into individual tokens.
 *
 * @param {string} value - Raw tag field string.
 * @returns {string[]}
 */
function splitTagString(value) {
  return value
    .split(/[\n,]/g)
    .map((entry) => entry.trim())
    .filter(Boolean);
}

/**
 * Loads extra metadata fields for template ids.
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase - Client.
 * @param {string[]} templateIds - Template ids.
 * @returns {Promise<Map<string, {tags: string[] | null, is_active: boolean | null, updated_at: string | null}>>}
 */
async function loadTemplateDetailsById(supabase, templateIds) {
  const map = new Map();
  if (templateIds.length === 0) {
    return map;
  }

  const { data, error } = await supabase
    .from('meme_templates')
    .select('id,tags,is_active,updated_at')
    .in('id', templateIds);

  if (error) {
    throw new HttpError(500, `Failed to load template details: ${error.message}`);
  }

  for (const row of data ?? []) {
    map.set(row.id, row);
  }

  return map;
}

/**
 * Creates signed image URLs for a list of storage paths.
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase - Client.
 * @param {string} bucket - Storage bucket.
 * @param {Array<string | null | undefined>} paths - Storage paths.
 * @returns {Promise<Map<string, string>>}
 */
async function loadSignedUrlsByPath(supabase, bucket, paths) {
  const result = new Map();
  const uniquePaths = Array.from(
    new Set(
      paths.filter((pathValue) => typeof pathValue === 'string' && pathValue),
    ),
  );

  if (uniquePaths.length === 0) {
    return result;
  }

  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrls(uniquePaths, SIGNED_URL_EXPIRES_IN_SECONDS);

  if (error) {
    throw new HttpError(500, `Failed to create signed URLs: ${error.message}`);
  }

  for (const entry of data ?? []) {
    if (typeof entry?.path === 'string' && typeof entry?.signedUrl === 'string') {
      result.set(entry.path, entry.signedUrl);
    }
  }

  return result;
}

/**
 * Creates one meme-template row from an uploaded file buffer.
 *
 * @param {{ supabase: import('@supabase/supabase-js').SupabaseClient, bucket: string, sourceBuffer: Buffer, tags: string[] }} params - Upload parameters.
 * @returns {Promise<any>}
 */
async function createTemplateFromUpload({ supabase, bucket, sourceBuffer, tags }) {
  const conversion = await convertImageToPngWithAspectRatio(sourceBuffer);
  const fileName = `${crypto.randomUUID()}.png`;

  await uploadTemplateObject(supabase, bucket, fileName, conversion.pngBuffer);

  const inserted = await insertTemplateRow({
    supabase,
    imagePath: fileName,
    aspectRatio: conversion.aspectRatio,
    tags,
  }).catch(async (insertError) => {
    await supabase.storage.from(bucket).remove([fileName]);
    throw insertError;
  });

  const signedUrl = await createSignedTemplateUrl(supabase, bucket, fileName);
  return mapTemplateRowToResponse(inserted, signedUrl);
}

/**
 * Converts any source image bytes to PNG and calculates aspect ratio.
 *
 * @param {Buffer} sourceBuffer - Source image bytes.
 * @returns {Promise<{ pngBuffer: Buffer, aspectRatio: number }>}
 */
async function convertImageToPngWithAspectRatio(sourceBuffer) {
  const conversion = await sharp(sourceBuffer)
    .rotate()
    .png({ compressionLevel: 9 })
    .toBuffer({ resolveWithObject: true });

  const width = Number(conversion.info.width ?? 0);
  const height = Number(conversion.info.height ?? 0);
  if (width <= 0 || height <= 0) {
    throw new Error('Unable to read image dimensions.');
  }

  return {
    pngBuffer: conversion.data,
    aspectRatio: width / height,
  };
}

/**
 * Uploads one template image object into storage.
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase - Supabase client.
 * @param {string} bucket - Storage bucket.
 * @param {string} imagePath - Destination image path.
 * @param {Buffer} imageBuffer - PNG image bytes.
 * @returns {Promise<void>}
 */
async function uploadTemplateObject(supabase, bucket, imagePath, imageBuffer) {
  const { error: uploadError } = await supabase.storage
    .from(bucket)
    .upload(imagePath, imageBuffer, {
      cacheControl: '3600',
      contentType: 'image/png',
      upsert: false,
    });

  if (uploadError) {
    throw new Error(`Failed to upload template image "${imagePath}": ${uploadError.message}`);
  }
}

/**
 * Creates one signed URL for a template image path.
 *
 * @param {import('@supabase/supabase-js').SupabaseClient} supabase - Supabase client.
 * @param {string} bucket - Storage bucket.
 * @param {string} imagePath - Storage object path.
 * @returns {Promise<string | null>}
 */
async function createSignedTemplateUrl(supabase, bucket, imagePath) {
  const { data, error } = await supabase.storage
    .from(bucket)
    .createSignedUrl(imagePath, SIGNED_URL_EXPIRES_IN_SECONDS);

  if (error) {
    throw new Error(`Failed to create signed URL for "${imagePath}": ${error.message}`);
  }

  return data?.signedUrl ?? null;
}

/**
 * Inserts a new meme-template row.
 *
 * @param {{ supabase: import('@supabase/supabase-js').SupabaseClient, imagePath: string, aspectRatio: number, tags: string[] }} params - Insert params.
 * @returns {Promise<any>}
 */
async function insertTemplateRow({ supabase, imagePath, aspectRatio, tags }) {
  const { data, error } = await supabase
    .from('meme_templates')
    .insert({
      image_path: imagePath,
      aspect_ratio: aspectRatio,
      tags,
      is_active: true,
    })
    .select('id,image_path,aspect_ratio,tags,is_active,created_at,updated_at')
    .single();

  if (error) {
    throw new HttpError(500, `Failed to insert meme template: ${error.message}`);
  }

  return data;
}

/**
 * Maps one template row to API response shape.
 *
 * @param {any} row - Database row.
 * @param {string | null} signedUrl - Signed image URL.
 * @returns {{ id: string, imagePath: string, aspectRatio: number, createdAt: string, updatedAt: string, tags: string[], isActive: boolean, signedUrl: string | null }}
 */
function mapTemplateRowToResponse(row, signedUrl) {
  return {
    id: row.id,
    imagePath: row.image_path,
    aspectRatio: Number(row.aspect_ratio),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    tags: Array.isArray(row.tags) ? row.tags : [],
    isActive: Boolean(row.is_active),
    signedUrl,
  };
}

/**
 * Normalizes RPC response shape.
 *
 * @param {unknown} rpcPage - Raw RPC payload.
 * @returns {{ items: Array<any>, nextCursorCreatedAt: string | null, nextCursorId: string | null }}
 */
function normalizeRpcPage(rpcPage) {
  if (!rpcPage || typeof rpcPage !== 'object') {
    return {
      items: [],
      nextCursorCreatedAt: null,
      nextCursorId: null,
    };
  }

  const items = Array.isArray(rpcPage.items) ? rpcPage.items : [];
  return {
    items,
    nextCursorCreatedAt: readOptionalString(rpcPage.next_cursor_created_at),
    nextCursorId: readOptionalString(rpcPage.next_cursor_id),
  };
}

/**
 * Converts unknown value to optional trimmed string.
 *
 * @param {unknown} value - Any raw value.
 * @returns {string | null}
 */
function readOptionalString(value) {
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

/**
 * Sanitizes secret env values.
 *
 * @param {unknown} value - Raw input value.
 * @returns {string}
 */
function sanitizeSecretValue(value) {
  if (typeof value !== 'string') {
    return '';
  }
  return value.trim();
}

/**
 * HTTP error wrapper with explicit status code.
 */
class HttpError extends Error {
  /**
   * @param {number} status - HTTP status code.
   * @param {string} message - Error message.
   */
  constructor(status, message) {
    super(message);
    this.name = 'HttpError';
    this.status = status;
  }
}

/**
 * @typedef {Object} LoadedEnvironmentConfig
 * @property {string} name
 * @property {string} fileName
 * @property {string} color
 * @property {string} supabaseUrl
 * @property {string} supabaseSecretKey
 * @property {string} storageBucket
 * @property {boolean} configured
 */
