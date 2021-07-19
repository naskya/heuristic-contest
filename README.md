# heuristic-contest

[AtCoder Heuristic Contest](https://atcoder.jp/contests/archive?ratedType=0&category=0&keyword=AtCoder+Heuristic+Contest) で以下のことを効率的に行うためのテンプレートです。解答に用いる言語が C++ であればこのテンプレートを使えます。

- テストケースを生成する。
- 求解するプログラムを一つのテストケースで実行し、得点と解の内容及びビジュアライズの結果を表示する。
- 求解するプログラムのデバッグを行う。
- 求解するプログラムを大量のテストケースで並列実行し、最低得点・最高得点・平均得点と最低(最高)得点を獲得したテストケースの名前を表示する。
- 求解するプログラムを一つのテストケースで実行し、求解途中の解のスナップショットを特定の時間 (デフォルトでは 10 ms) ごとに取得して点数の時間変化を折れ線グラフで表示する。また、解の時間変化を動画で表示する。

# 作業用リポジトリの作成

このリポジトリの fork や clone を行って問題を解くためにそのまま使用してもよいですが、問題を解く際にこのリポジトリに既に存在しているコミット履歴を参照する必要は無いので GitHub のテンプレート機能を利用して 1 つの問題に対して新しいリポジトリを 1 つ作成することをおすすめします(問題を解きながら、アルゴリズムの変更を行った場合などに変更内容や獲得した点数をコミットメッセージに記録していくようにするとよいかもしれません)。テンプレート機能を利用して新しいリポジトリを作成するには、[このリポジトリのページ](https://github.com/naskya/heuristic-contest) にある "Use this template" と書かれたボタンをクリックします。公開設定を public にすると書いた解答を push した時にその内容が公開されることに注意してください。コンテスト中に解答を公開するとルール違反となるので、コンテストが終了するまでは公開設定を private にしておくことを強く推奨します(終了後に公開設定を public に変更することもできます)。

![リポジトリの作成画面](https://naskya.net/share/github/naskya/heuristic-contest/readme_01.png)

リポジトリを作成したら、ローカルに clone するなどして使用します。

問題を解くのではなく、このテンプレートの内容そのものを編集して機能の追加やバグの修正などをしていただけるのであれば、このリポジトリを fork してください。Issue や Pull Request は歓迎します(必ず取り込まれるとは限りませんが)。

# 使い方

1. `visualizer` ディレクトリに AtCoder 公式で提供されているビジュアライザをそのまま入れます。`visualizer` ディレクトリ直下に `Cargo.toml` がある状態にしてください。
1. `make files=500 gen` を実行して、 `test/in` ディレクトリ内にテストケースを生成します。`files=500` の部分は生成する数の指定で、省略すると 500 個のテストケースが生成されます。このコマンドは毎回 `test/in` ディレクトリの内容を置き換えるので、テストケースの数が多すぎたり少なすぎたりした場合にはもう一度このコマンドを実行するとよいです。
1. `src/main.cpp` に解答を書きます。解答の書き方は `how_to_write_solution.md` を参考にしてください。
1. `utility/calc_score.cpp` に「標準入力からテストの入力と出力を順番に受け取り、スコアを標準出力に出力するプログラム」を書きます。
1. 以上の手順が完了したら、以下のコマンドを使用することができます。`case=0000` の部分はテストケース名で、好きに変えることができます。テストケースを指定しないと `test/in/0000.txt` が使用されます。
    - `make case=0000 normal`: 通常の実行を行い以下の内容を出力する
        - 点数
        - 解の内容
        - 解のビジュアライズ (1 枚の画像)
    - `make case=0000 debug`: デバッグ実行する
    - `make case=0000 debugger`: プログラムをデバッガを用いて実行する
        - プログラムは `main` 関数に入ってすぐに一時停止され、操作(実行を続ける・ステップ実行する・ブレークポイントを作るなど)を待つ状態になります。
    - `make case=0000 graph`: スコアの遷移のグラフを作成する
    - `make case=0000 mov`: スコアと解が遷移する様子を見られるグラフと動画を作成する
    - `make multi`: 全てのケースを並列で実行し以下の内容を出力する
        - 最低点
        - 最低点を出したテストケース名
        - 最高点
        - 最高点を出したテストケース名
        - 平均点

# 注意

- Windows Subsystem for Linux を利用していない場合、または Windows Subsystem for Linux を利用していて Windows のローカルドライブをマウントしていない場合には `Makefile` の 10 行目の `OPEN = ...` の右辺を、動画や画像のファイル名を引数として与えるとそれらをビューアーで開く機能を持つ別のコマンドに変更する必要があります。
- 解をビジュアライズして表示する機能を使用するには [ffmpeg](http://ffmpeg.org/) のインストールが必要です。パッケージマネージャからインストールできるものをそのままインストールするのではなく、ソースコードをダウンロードして `--enable-librsvg, --enable-gpl, --enable-libx264` フラグを有効化してビルドしたものを用いる必要があります。
- デバッガ上でプログラムを実行する機能を使用するには [GDB](https://www.gnu.org/software/gdb/) または [LLDB](https://lldb.llvm.org/) のインストールが必要です。LLDB を使用する場合は `Makefile` の 15 行目の `DEBUGGER = gdb` の右辺を LLDB を起動するコマンド (`lldb` など) に書き換え、91 行目をコメントアウトして 92 行目のコメントアウトを解除してください。
- C++ のソースファイルをコンパイルするコマンドを `clang++` に変更したい場合は 2 行目の `CXX = g++` を `CXX = clang++` に変更するなど、他にも設定の変更が必要な場合は `Makefile` の編集を行ってください。
