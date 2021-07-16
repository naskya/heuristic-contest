# 使い方

*1. 使用には [ffmpeg](http://ffmpeg.org/) のインストールが必要です。パッケージマネージャから配布されているものをそのままインストールするのではなく、ソースコードをダウンロードして `--enable-librsvg, --enable-gpl, --enable-libx264` フラグを有効化してビルドしたものを用いる必要があります。

*2. Windows Subsystem for Linux を利用していない場合、または Windows Subsystem for Linux の中で Windows のローカルドライブをマウントしていない場合には `makefile` の 10 行目の `OPEN = ...` の右辺を、動画や画像のファイル名を引数として与えるとそれらをビューアーで開く機能を持つ別のコマンドに変更する必要があります。他にも、C++ のソースファイルをコンパイルするコマンドを `clang++` に変更したい場合は 2 行目の `CXX = g++` を `CXX = clang++` に変更するなど、環境に応じた設定の変更が必要な場合は `makefile` の編集を行ってください。

0. [このリポジトリのページ](https://github.com/naskya/heuristic-contest) にある "Use this template" と書かれたボタンをクリックし、1 つの問題に対して 1 つのリポジトリを作成します。リポジトリの fork や clone を行ってもよいですが、問題を解く際には過去のコミットを参照する必要が無いのでこの機能を使うことをおすすめします。リポジトリを public にすると、書いた解答を push した場合その内容が公開されることに注意してください。コンテスト中はリポジトリを private にしておくことをおすすめします。![リポジトリの作成画面](https://naskya.net/share/github/naskya/heuristic-contest/readme_01.png)
1. `visualizer` ディレクトリに AtCoder 公式で提供されているビジュアライザをそのまま入れます。`visualizer` ディレクトリ直下に `Cargo.toml` がある状態にしてください。
1. `make files=500 gen` を実行して、 `test/in` ディレクトリ内にテストケースを生成します。`files=500` の部分は生成する数の指定で、省略すると 500 個のテストケースが生成されます。このコマンドは毎回 `test/in` ディレクトリの内容を置き換えるので、テストケースの数が多すぎたり少なすぎたりした場合にはもう一度このコマンドを実行するとよいです。
1. 解答は `src/main.cpp` に書きます。
    - はじめに、63 行目の `time_limit` の値を問題の実行時間制限に合わせて変更し(単位は ms)、129 行目の `threads` の値を使っている PC のスレッド数(またはそれより少し小さい数)に変更してください。
    - 95 行目にある `struct result` が解答として出力する内容を表すようにコードを編集します。例えば [AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) では出力するものが 4 つの数の配列なので
      ```C++
      struct result {
        std::vector<int> a, b, c, d;
      };
      ```
      などとします。
    - `struct result` のすぐ下にある `print` 関数を、解答を表す変数 `res` を受け取ってその内容を `os` に出力するように書き換えます。`std::cout` の代わりに `os` を使うのだと思っておけばよいです。[AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) の例では
      ```C++
      void print(std::ostream& os, const result& res) {
        for (std::size_t i = 0u; i < std::size(res.a); i++)
          os << res.a[i] << ' ' << res.b[i] << ' '
             << res.c[i] << ' ' << res.d[i] << '\n';
      }
      ```
      などとします。
    - `solve` 関数内の `// declare variables` と書いてある部分で入力する変数の宣言を行い、その下にあるラムダ式 `scan` の中に入力を `is` から読むコードを書きます。`std::cin` の代わりに `is` を使うのだと思っておけばよいです。[AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) の例では
      ```C++
      // declare variables
      int n;
      std::vector<int> x, y, r;

      const auto scan = [&] {
        // read inputs
        is >> n;
        x = y = r = std::vector<int>(n);
        for (int i = 0; i < n; i++)
          is >> x[i] >> y[i] >> r[i];
      };
      ```
      などとします。
    - あとは `// initialize solution` と書いてある部分で解(`res` という変数です)の初期化を行い、`// improve solution` と書いてある部分で解を改善するようにします。最後に標準出力に解を出力したりする必要はありません。求解が終わると `print` 関数が呼ばれて解が出力されるようになっています。テンプレートはある程度改変して使っても構いませんが、`END_MAINLOOP` や `END_SOLVE_FUNC` を書く位置などには気をつけてください。
    - 求解のプログラムは並列で実行されるので、競合(一つの変数に複数のスレッドが同時に書き込みを行うなど)が発生しないように気をつけてください。例えば、グローバル変数を用意してそこに書き込みを行うなどは避けるべきです。
1. 解答を書いたら、今度は `utility/calc_score.cpp` に「標準入力からテストの入力と出力を受け取り、スコアを標準出力に出力するプログラム」を書きます。
1. 以上の手順が完了したら、以下のコマンドを使用することができます。`case=0000` の部分はテストケース名で、好きに変えることができます。テストケースを指定しないと `test/in/0000.txt` が使用されます。
    - `make case=0000 normal`: 通常の実行を行い以下の内容を出力する
        - 点数
        - 解のビジュアライズ (1 枚の画像)
    - `make case=0000 debug`: デバッグ実行する
    - `make case=0000 graph`: スコアの遷移のグラフを作成する
    - `make case=0000 mov`: スコアと解が遷移する様子を見られるグラフと動画を作成する
    - `make multi`: 全てのケースを並列で実行し以下の内容を出力する
        - 最低点
        - 最低点を出したテストケース名
        - 最高点
        - 最高点を出したテストケース名
        - 平均点

より詳しい内容は[このページ](https://naskya.net/post/0004/)に書いてあります。
