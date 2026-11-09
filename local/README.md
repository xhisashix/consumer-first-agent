# Local Overrides (`local/`)

このディレクトリ配下（`local/agents/`, `local/skills/`, `local/rules/`）は `.gitignore` によって **Git管理から除外** されています。

## 使いどころ
- **会社PC専用のファイル**: 社内規定、社内システムのURL、非公開プロジェクト固有のサブエージェントやスキルなど、個人のGitリポジトリにPushしたくないものを配置します。
- **プライベートPC専用のファイル**: 個人環境でのみ使う実験的なエージェントやスキルを配置します。

`./scripts/setup-links.sh` を実行すると、通常の `agents/`・`skills/`・`rules/` に加えて、この `local/` 内に置かれたファイルも自動的に各ツール（Antigravity / GitHub Copilot / Claude Code）へシンボリックリンク展開されます。
