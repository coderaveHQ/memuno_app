const state = {
  environments: [],
  selectedEnvironment: 'development',
  search: '',
  items: [],
  nextCursorCreatedAt: null,
  nextCursorId: null,
  hasMore: false,
  loading: false,
};

const elements = {
  environmentSelect: document.getElementById('environment-select'),
  environmentBadge: document.getElementById('environment-badge'),
  uploadForm: document.getElementById('upload-form'),
  uploadFiles: document.getElementById('upload-files'),
  uploadFileTags: document.getElementById('upload-file-tags'),
  uploadButton: document.getElementById('upload-button'),
  searchInput: document.getElementById('search-input'),
  searchButton: document.getElementById('search-button'),
  clearSearchButton: document.getElementById('clear-search-button'),
  statusText: document.getElementById('status-text'),
  errorText: document.getElementById('error-text'),
  templatesGrid: document.getElementById('templates-grid'),
  loadMoreButton: document.getElementById('load-more-button'),
  templateCardTemplate: document.getElementById('template-card-template'),
};

void initialize();

/**
 * Initializes the tools UI.
 */
async function initialize() {
  bindEvents();
  renderUploadFileTagInputs();
  await loadEnvironments();
  await loadTemplates({ reset: true });
}

/**
 * Binds DOM event handlers.
 */
function bindEvents() {
  elements.environmentSelect.addEventListener('change', async (event) => {
    state.selectedEnvironment = event.target.value;
    renderEnvironmentBadge();
    await loadTemplates({ reset: true });
  });

  elements.searchButton.addEventListener('click', async () => {
    state.search = elements.searchInput.value.trim();
    await loadTemplates({ reset: true });
  });

  elements.clearSearchButton.addEventListener('click', async () => {
    elements.searchInput.value = '';
    state.search = '';
    await loadTemplates({ reset: true });
  });

  elements.searchInput.addEventListener('keydown', async (event) => {
    if (event.key !== 'Enter') {
      return;
    }
    event.preventDefault();
    state.search = elements.searchInput.value.trim();
    await loadTemplates({ reset: true });
  });

  elements.loadMoreButton.addEventListener('click', async () => {
    await loadTemplates({ reset: false });
  });

  elements.uploadFiles.addEventListener('change', () => {
    renderUploadFileTagInputs();
  });

  elements.uploadForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    await uploadTemplate();
  });
}

/**
 * Renders one tag input per currently selected file.
 */
function renderUploadFileTagInputs() {
  const fileTagsHost = elements.uploadFileTags;
  const files = Array.from(elements.uploadFiles.files ?? []);

  /** @type {Map<string, string>} */
  const existingByKey = new Map();
  for (const input of fileTagsHost.querySelectorAll('.upload-file-tags-input')) {
    const fileKey = input.dataset.fileKey;
    if (typeof fileKey === 'string') {
      existingByKey.set(fileKey, input.value);
    }
  }

  fileTagsHost.innerHTML = '';

  if (files.length === 0) {
    const emptyText = document.createElement('p');
    emptyText.className = 'hint-text';
    emptyText.textContent = 'Optional: add tags per selected image.';
    fileTagsHost.append(emptyText);
    return;
  }

  for (const [index, file] of files.entries()) {
    const fileKey = buildSelectedFileKey(file);

    const row = document.createElement('div');
    row.className = 'upload-file-tag-row';

    const name = document.createElement('div');
    name.className = 'upload-file-name';
    name.textContent = `${index + 1}. ${file.name}`;
    row.append(name);

    const field = document.createElement('label');
    field.className = 'field';

    const label = document.createElement('span');
    label.textContent = 'Tags (comma separated)';
    field.append(label);

    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'upload-file-tags-input';
    input.placeholder = 'funny, reaction';
    input.dataset.fileIndex = String(index);
    input.dataset.fileKey = fileKey;
    input.value = existingByKey.get(fileKey) ?? '';
    field.append(input);

    row.append(field);
    fileTagsHost.append(row);
  }
}

/**
 * Builds a deterministic key for one selected file.
 *
 * @param {File} file - Browser File object.
 * @returns {string}
 */
function buildSelectedFileKey(file) {
  return `${file.name}::${file.size}::${file.lastModified}`;
}

/**
 * Collects one raw tag string per selected file index.
 *
 * @param {number} fileCount - Number of selected files.
 * @returns {string[]}
 */
function collectUploadTagsByIndex(fileCount) {
  const tagsByIndex = Array.from({ length: fileCount }, () => '');
  for (const input of elements.uploadFileTags.querySelectorAll('.upload-file-tags-input')) {
    const index = Number.parseInt(input.dataset.fileIndex ?? '', 10);
    if (!Number.isNaN(index) && index >= 0 && index < fileCount) {
      tagsByIndex[index] = input.value;
    }
  }
  return tagsByIndex;
}

/**
 * Loads available environment metadata from backend.
 */
async function loadEnvironments() {
  clearError();

  const response = await fetch('/api/environments');
  if (!response.ok) {
    setError('Failed to load environments.');
    return;
  }

  const payload = await response.json();
  state.environments = Array.isArray(payload.environments)
    ? payload.environments
    : [];

  const bestEnvironment =
    state.environments.find((item) => item.name === 'development' && item.configured)
      ?.name ??
    state.environments.find((item) => item.configured)?.name ??
    'development';

  state.selectedEnvironment = bestEnvironment;
  renderEnvironmentSelect();
  renderEnvironmentBadge();
}

/**
 * Renders environment dropdown options.
 */
function renderEnvironmentSelect() {
  elements.environmentSelect.innerHTML = '';

  for (const environment of state.environments) {
    const option = document.createElement('option');
    option.value = environment.name;
    option.textContent = environment.configured
      ? environment.label
      : `${environment.label} (missing config)`;
    option.disabled = !environment.configured;
    option.selected = environment.name === state.selectedEnvironment;
    elements.environmentSelect.append(option);
  }
}

/**
 * Renders the active environment badge.
 */
function renderEnvironmentBadge() {
  const activeEnvironment = state.environments.find(
    (item) => item.name === state.selectedEnvironment,
  );

  const color = activeEnvironment?.color ?? 'green';
  elements.environmentBadge.className = `environment-badge ${color}`;
  elements.environmentBadge.textContent = activeEnvironment?.label ?? state.selectedEnvironment;
}

/**
 * Loads a template page.
 *
 * @param {{ reset: boolean }} options - Loading options.
 */
async function loadTemplates(options) {
  if (state.loading) {
    return;
  }

  state.loading = true;
  clearError();
  setStatus('Loading templates...');
  updateActionStates();

  if (options.reset) {
    state.items = [];
    state.nextCursorCreatedAt = null;
    state.nextCursorId = null;
    state.hasMore = false;
    renderTemplates();
  }

  try {
    const query = new URLSearchParams();
    query.set('environment', state.selectedEnvironment);
    query.set('limit', '24');

    if (state.search) {
      query.set('search', state.search);
    }

    if (!options.reset && state.nextCursorCreatedAt && state.nextCursorId) {
      query.set('cursorCreatedAt', state.nextCursorCreatedAt);
      query.set('cursorId', state.nextCursorId);
    }

    const response = await fetch(`/api/templates?${query.toString()}`);
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.message ?? 'Failed to load templates.');
    }

    const receivedItems = Array.isArray(payload.items) ? payload.items : [];
    if (options.reset) {
      state.items = receivedItems;
    } else {
      const existingById = new Map(state.items.map((item) => [item.id, item]));
      for (const item of receivedItems) {
        existingById.set(item.id, item);
      }
      state.items = Array.from(existingById.values());
    }

    state.nextCursorCreatedAt = payload.nextCursorCreatedAt ?? null;
    state.nextCursorId = payload.nextCursorId ?? null;
    state.hasMore = Boolean(state.nextCursorCreatedAt && state.nextCursorId);

    renderTemplates();
    setStatus(
      `${state.items.length} template(s) loaded${
        state.search ? ` for "${state.search}"` : ''
      }.`,
    );
  } catch (error) {
    setError(error instanceof Error ? error.message : 'Unknown loading error.');
    setStatus('');
  } finally {
    state.loading = false;
    updateActionStates();
  }
}

/**
 * Renders template cards.
 */
function renderTemplates() {
  elements.templatesGrid.innerHTML = '';

  if (state.items.length === 0) {
    const emptyText = document.createElement('p');
    emptyText.className = 'status-text';
    emptyText.textContent = 'No templates found.';
    elements.templatesGrid.append(emptyText);
    return;
  }

  for (const item of state.items) {
    const fragment = elements.templateCardTemplate.content.cloneNode(true);
    const card = fragment.querySelector('.template-card');
    const image = fragment.querySelector('.template-image');
    const idText = fragment.querySelector('.template-id');
    const tagsInput = fragment.querySelector('.template-tags-input');
    const saveButton = fragment.querySelector('.template-save-button');

    image.src = item.signedUrl ?? '';
    image.style.aspectRatio = String(Math.max(item.aspectRatio || 1, 0.2));
    image.addEventListener('error', () => {
      image.alt = 'Template image unavailable';
    });

    idText.textContent = item.id;
    tagsInput.value = Array.isArray(item.tags) ? item.tags.join(', ') : '';

    saveButton.addEventListener('click', async () => {
      await updateTemplateTags(item.id, tagsInput.value, saveButton);
    });

    card.dataset.templateId = item.id;
    elements.templatesGrid.append(fragment);
  }
}

/**
 * Updates one template's tags.
 *
 * @param {string} templateId - Template id.
 * @param {string} rawTags - Raw tag input.
 * @param {HTMLButtonElement} button - Trigger button.
 */
async function updateTemplateTags(templateId, rawTags, button) {
  button.disabled = true;
  clearError();
  setStatus(`Saving tags for ${templateId}...`);

  try {
    const response = await fetch(`/api/templates/${templateId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        environment: state.selectedEnvironment,
        tags: rawTags,
      }),
    });

    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.message ?? 'Failed to update tags.');
    }

    const target = state.items.find((item) => item.id === templateId);
    if (target) {
      target.tags = Array.isArray(payload.tags) ? payload.tags : [];
    }

    setStatus(`Saved tags for ${templateId}.`);
  } catch (error) {
    setError(error instanceof Error ? error.message : 'Unknown update error.');
    setStatus('');
  } finally {
    button.disabled = false;
  }
}

/**
 * Uploads one or many new template images.
 */
async function uploadTemplate() {
  clearError();
  const files = Array.from(elements.uploadFiles.files ?? []);
  if (files.length === 0) {
    setError('Please choose at least one image file.');
    return;
  }

  setStatus(`Uploading ${files.length} file(s)...`);
  elements.uploadButton.disabled = true;

  try {
    const tagsByIndex = collectUploadTagsByIndex(files.length);

    const formData = new FormData();
    formData.set('environment', state.selectedEnvironment);
    formData.set('tagsByIndex', JSON.stringify(tagsByIndex));
    for (const file of files) {
      formData.append('files', file);
    }

    const response = await fetch('/api/templates', {
      method: 'POST',
      body: formData,
    });
    const payload = await response.json();

    if (!response.ok) {
      throw new Error(payload.message ?? 'Failed to upload template.');
    }

    const convertedCount = Number(payload.convertedCount ?? 0);
    const failedCount = Number(payload.failedCount ?? 0);
    const failureSummary = formatFailureSummary(payload.failed);
    setStatus(
      `Upload finished. Converted: ${convertedCount}. Failed: ${failedCount}.${failureSummary}`,
    );
    elements.uploadForm.reset();
    renderUploadFileTagInputs();

    await loadTemplates({ reset: true });
  } catch (error) {
    setError(error instanceof Error ? error.message : 'Unknown upload error.');
    setStatus('');
  } finally {
    elements.uploadButton.disabled = false;
  }
}

/**
 * Formats API failure arrays into a compact status suffix.
 *
 * @param {unknown} failedItems - API failed item payload.
 * @returns {string}
 */
function formatFailureSummary(failedItems) {
  if (!Array.isArray(failedItems) || failedItems.length === 0) {
    return '';
  }

  const preview = failedItems
    .slice(0, 3)
    .map((item) => item?.message)
    .filter((message) => typeof message === 'string' && message.trim().length > 0);

  if (preview.length === 0) {
    return '';
  }

  return ` First errors: ${preview.join(' | ')}`;
}

/**
 * Updates loading-dependent button states.
 */
function updateActionStates() {
  elements.loadMoreButton.disabled = state.loading || !state.hasMore;
  if (state.loading) {
    elements.loadMoreButton.textContent = 'Loading...';
    return;
  }
  elements.loadMoreButton.textContent = state.hasMore ? 'Load More' : 'No More Templates';
}

/**
 * Sets status text.
 *
 * @param {string} message - Message text.
 */
function setStatus(message) {
  elements.statusText.textContent = message;
}

/**
 * Sets error text.
 *
 * @param {string} message - Error text.
 */
function setError(message) {
  elements.errorText.textContent = message;
}

/**
 * Clears error text.
 */
function clearError() {
  elements.errorText.textContent = '';
}
