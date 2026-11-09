# Marketing Waza Multi-Agent Suite (`agent-marketing-waza`)

**Antigravity / Claude Code / GitHub Copilot** の3環境すべてに対応した、**マルチプラットフォームAIプラグイン**です。
P&G型のブランドマネジメント体制および「Marketing Waza」の思考体系に基づく全10担当のサブエージェントとスキルをパッケージ化しています。

すべてのサブエージェント・スキルは **「モードA：エンジニアリング・開発マネジメントモード」** と **「モードB：マーケティング戦略・事業推進モード」** の2モードに対応しており、普段のコーディング・バグ修正タスクには干渉しないガードレールを備えています。

---

## 1. プラグインとしてのインストール方法（シェルスクリプト不要）

このリポジトリは各ツールの公式プラグイン仕様に準拠しているため、**シェルスクリプトを実行することなく**、各ツールの標準機能だけで導入・更新できます。

### ① Antigravity での導入
以下のコマンドでプラグインとして直接インストールできます（または `~/.gemini/config/plugins/agent-marketing-waza` に `git clone` するだけでも自動認識されます）。

```bash
agy plugin install <このGitリポジトリのURL または ローカルパス>
```
- 導入後は Antigravity の **Customizations（Plugins）画面** から1クリックで ON / OFF を切り替えられます。

### ② Claude Code での導入
`.claude-plugin/plugin.json` を同梱しているため、Claude Code の標準プラグインコマンドで直接インストールできます。

```bash
# Claude Code のチャットセッション内で実行
/plugin

# または CLI から検証・導入
claude plugin validate .
```

### ③ GitHub Copilot (VS Code) での導入
リポジトリ内の `.github/agents/*.agent.md` に相対リンクを同梱しているため、VS Code の個人設定（`settings.json`）に以下の2行を追加するだけで、全プロジェクト横断で利用できます（VS Code の Settings Sync を使えばプライベートPCと会社PCで設定も自動同期されます）。

```json
{
  "chat.agentFilesLocations": [
    "/path/to/agent-marketing-waza/.github/agents"
  ],
  "chat.agentSkillsLocations": [
    "/path/to/agent-marketing-waza/skills"
  ]
}
```

---

## 2. 搭載サブエージェント＆スキル一覧（全10担当＋統括オーケストレーター）

| No | 識別名 (`name`) | 担当ロール | 主な成果物 |
| :-: | :--- | :--- | :--- |
| **統括** | `marketing-waza-orchestrator` | マルチエージェント連携パイプライン統括スキル | 複数担当の一気通貫連携 |
| **①** | `marketing-waza-brand-manager` | ブランドマネージャー（全体統括・WHO/WHAT/HOW戦略・エクイティ担当） | WHO / WHAT / HOW 戦略定義シート |
| **②** | `marketing-waza-cmk-researcher` | CMK / 顧客理解・リサーチ担当（3つの顔・行動×知覚・顧客我） | CMK リサーチ設計＆顧客インサイト仮説シート |
| **③** | `marketing-waza-concept-innovator` | コンセプト開発・イノベーション担当（Connecting Dots・50字アイデア・RTB） | イノベーション＆コンセプト開発シート |
| **④** | `marketing-waza-creative-director` | クリエイティブ・広告制作担当（ブリーフ・アイデア×ドラマ・SMILE評価） | クリエイティブブリーフ＆コミュニケーション評価シート |
| **⑤** | `marketing-waza-digital-pr-strategist` | デジタル・PR・インフルエンサー戦略担当（バリア打破・インフルエンサーマップ・UGC） | デジタル・PR・インフルエンサー戦略設計シート |
| **⑥** | `marketing-waza-scientific-sales` | 科学的営業・トレードマーケティング担当（4大課題・DPSM×VECTR・5ステップ話法） | 科学的営業・トレードマーケティング戦略＆商談設計シート |
| **⑦** | `marketing-waza-financial-strategist` | ファイナンシャル戦略（PL・収益管理・限界利益率・3年予測・投資ROI）担当 | ファイナンシャル戦略＆3年PL・投資回収シミュレーションシート |
| **⑧** | `marketing-waza-memo-writer-pro` | One Page Memo ライティング・添削担当（Approval型・Report型1/2・和田氏の鉄の掟） | 完成版 One Page Memo ＆ 鉄の掟セルフチェック |
| **⑨** | `marketing-waza-leadership-oneteam` | リーダーシップ・ワンチーム推進担当（26の行動原則・ジョハリの窓・権限移譲） | ワンチーム推進＆リーダーシップ行動計画シート |
| **⑩** | `marketing-waza-talent-developer` | 人材育成・スキル評価担当（スキル分解・70:20:10・KSA・OJTブリーフ・W&DP） | 人材育成スキルマップ ＆ W&DP・OJTブリーフィング設計シート |

---

## 3. ディレクトリ構成（ユニバーサル・プラグイン構造）

```text
agent-marketing-waza/
├── plugin.json                # Antigravity 用プラグインマニフェスト
├── .claude-plugin/
│   └── plugin.json            # Claude Code 用プラグインマニフェスト
├── .github/
│   └── agents/                # GitHub Copilot 用（../../agents/*.md への相対リンク）
│       └── marketing-waza-*.agent.md
├── assets/
│   └── logo.svg               # プラグインロゴアイコン
├── AGENTS.md                  # -> rules/AGENTS.md へのシンボリックリンク
├── rules/
│   └── AGENTS.md              # [正本] オーケストレーション＆通常開発への非干渉ガードレール規約
├── agents/
│   └── marketing-waza-*.md    # [正本] 全10担当のサブエージェント定義
├── skills/
│   └── marketing-waza-*/      # [正本] 全10担当＋オーケストレーターのスキル定義（SKILL.md）
└── templates/                 # 新規エージェント・スキル追加時の雛形
    ├── agent-template.md
    └── skill-template/SKILL.md
```
