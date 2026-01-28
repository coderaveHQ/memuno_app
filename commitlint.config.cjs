/**
 * -----------------------------------------------------------------------------
 * Commitlint configuration
 * -----------------------------------------------------------------------------
 * Conventional Commits:
 *
 *   <type>(<scope>): <subject>   // scope optional in this project
 *   <type>: <subject>            // allowed
 *
 * Examples:
 *   feat: add otp sign-in flow
 *   feat(auth): add otp sign-in flow
 *   fix(ci): correct caching key
 * -----------------------------------------------------------------------------
 */
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "perf",
        "test",
        "build",
        "ci",
        "chore",
        "revert",
      ],
    ],

    /**
     * Scope is optional.
     */
    "scope-empty": [0],
    "scope-case": [0],

    "subject-case": [2, "never", ["sentence-case", "start-case", "pascal-case"]],
    "subject-empty": [2, "never"],
    "header-max-length": [2, "always", 100],
  },
};
