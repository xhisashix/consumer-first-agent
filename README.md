# agent-marketing-waza

**Antigravity / GitHub Copilot / Claude Code** の3環境でサブエージェント・スキル・オーケストレーション規約を一元管理し、**プライベートPC・会社PC・複数プロジェクト間でポータブルに使い回すための「AIエージェント版 dotfiles」リポジトリ**です。

---

## ディレクトリ構成

```text
agent-marketing-waza/
├── plugin.json                # Antigravity プラグインマニフェスト
├── AGENTS.md                  # rules/AGENTS.md へのシンボリックリンク
├── rules/
│   └── AGENTS.md              # [正本] 親エージェントのオーケストレーション・ルーティング規約
├── agents/
│   └── _template.md           # [正本] サブエージェント定義置き場（_template.md をコピーして作成）
├── skills/
│   └── _template/
│       └── SKILL.md           # [正本] スキル定義置き場（_template フォルダをコピーして作成）
├── local/                     # [Git除外] 会社PC専用・個人PC専用の非公開ルール/スキル/エージェント置き場
│   ├── README.md
│   ├── rules/
│   ├── agents/
│   └── skills/
└── scripts/
    └── setup-links.sh         # 3ツールへのシンボリックリンク一括展開・管理スクリプト
```

> **Note**: `_`（アンダースコア）から始まるファイル・フォルダ（`_template.md` や `_template/`）はテンプレート用のため、`setup-links.sh` 実行時には自動的にスキップされます。

---

## クイックスタート（プライベートPC / 会社PC での初期セットアップ）

新しいPCにリポジトリをクローンしたら、以下の1コマンドを実行するだけでPC全体（グローバル環境）にリンクが張られます。

```bash
./scripts/setup-links.sh --global
```

### `--global` でリンクされる場所
| ツール | リンク先パス |
| :--- | :--- |
| **Antigravity** | `~/.gemini/config/plugins/agent-marketing-waza` |
| **Claude Code** | `~/.claude/rules/`, `~/.claude/agents/*.md`, `~/.claude/skills/*` |
| **GitHub Copilot** | `~/.copilot/agents/*.agent.md` *(自動で拡張子変換)*, `~/.copilot/skills/*` |

---

## 新しいスキル・サブエージェントの作り方

### 1. スキル（専門知識・手順書）を追加する
```bash
cp -r skills/_template skills/market-research
# skills/market-research/SKILL.md を編集
```

### 2. サブエージェントを追加する
```bash
cp agents/_template.md agents/researcher.md
# agents/researcher.md を編集
```

### 3. リンクを更新する
新しいファイルやフォルダを追加したときは、以下を再実行すると各ツールへリンクが追加されます（既存ファイルの中身を編集しただけの場合は再実行不要です）。
```bash
./scripts/setup-links.sh --global
```

---

## 便利なコマンド一覧

```bash
# 現在のエージェント・スキル一覧とリンク状態を確認
./scripts/setup-links.sh --status

# 特定の別プロジェクト（リポジトリ）内にだけローカル展開したい場合
./scripts/setup-links.sh --project /path/to/your-project

# グローバルリンクを安全に解除したい場合
./scripts/setup-links.sh --unlink-global
```
