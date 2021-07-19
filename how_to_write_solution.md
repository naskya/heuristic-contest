# このファイルについて

`src/main.cpp` に解答を書く方法の説明です。この説明は `src/main.cpp` を見ながら読んでください。

# `src/main.cpp` で定義されているクラス

## `utility::timer` (69 行目)

実行時間を計るために使うクラスです。`solve` 関数の先頭でこの型のオブジェクトを構築して計測を開始します。

### メンバ関数

#### good()

実行時間が制限時間に達していない場合に `true` を、そうでない場合に `false` を返します。制限時間まで処理を繰り返し行いたい時には以下のようにします。

```C++
const utility::timer tm;

while (tm.good()) {
  // 処理
}
```

#### frac<a, b>()

実行時間が制限時間の a/b 倍に達していない場合に `true` を、そうでない場合に `false` を返します。制限時間の半分まで処理 A を、それ以降は制限時間まで処理 B を行いたい時には以下のようにします。

```C++
const utility::timer tm;

while (tm.frac<1, 2>()) {
  // 処理 A
}

while (tm.good()) {
  // 処理 B
}
```

#### elapsed()

経過時間を ms の単位で除算した値を返します。

```C++
const utility::timer tm;

// 300 ms 間待機
std::this_thread::sleep_for(std::chrono::milliseconds(300));

auto t = tm.elapsed();  // t は 300 に近い値
```

## `utility::random_number_generator` (90 行目)

乱数生成に使用するクラスです。`operator ()` の引数に乱数の分布を与えると乱数が得られます。

```C++
utility::random_number_generator rng;

// 0 以上 100 以下の整数の一様分布
std::uniform_int_distribution  dist_i(0, 100);
// 0 以上 1 未満の実数の一様分布
std::uniform_real_distribution dist_d(0.0, 1.0);

auto r1 = rng(dist_i);  // r1 は 0 以上 100 以下の int 型の値
auto r2 = rng(dist_d);  // r2 は 0 以上 1 未満の double 型の値
```

## `result` (101 行目)

解として出力するものを保持するクラスです。

# 解答の手順

1. 74 行目の `time_limit` の値を問題の実行時間制限に合わせて変更します(単位は ms)。20 ms 程度は余裕を持たせることをおすすめします。
1. 135 行目の `threads` の値を使っている PC に搭載されている CPU のスレッド数(またはそれより少し小さい数)に変更します。
1. 101 行目の `struct result` が解答として出力する内容を表すようにコードを編集します。例えば [AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) では出力するものが 4 つの数の配列なので
   ```C++
   struct result {
     std::vector<int> a, b, c, d;
   };
   ```
   などとします。
1. `struct result` のすぐ下にある `print` 関数を、解答を表す変数 `res` を受け取ってその内容を `os` に出力するように書き換えます。`std::cout` の代わりに `os` を使うのだと考えてください。[AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) の例では
   ```C++
   void print(std::ostream& os, const result& res) {
     for (std::size_t i = 0; i < std::size(res.a); i++)
       os << res.a[i] << ' ' << res.b[i] << ' '
          << res.c[i] << ' ' << res.d[i] << '\n';
   }
   ```
   などとします。
1. `solve` 関数内の `// declare variables` と書いてある部分で入力する変数の宣言を行い、その下にあるラムダ式 `scan` の中に入力を `is` から読むコードを書きます。`std::cin` の代わりに `is` を使うのだと考えてください。[AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) の例では
   ```C++
   // declare variables
   int n;
   std::vector<int> x, y, r;

   const auto scan = [&] {
     // read inputs
     is >> n;

     x.resize(n);
     y.resize(n);
     r.resize(n);

     for (int i = 0; i < n; i++)
       is >> x[i] >> y[i] >> r[i];
   };
   ```
   などとします。
1. `// initialize solution` と書いてある部分で解の初期化を行います。解は新たに宣言するのではなく、`solve` 関数の引数として与えられている `result` 型の変数 `res` を使ってください。[AHC001](https://atcoder.jp/contests/ahc001/tasks/ahc001_a) の例で、面積が 1 の正方形を初期解とするなら
   ```C++
   // initialize solution
   res.a.resize(n);
   res.b.resize(n);
   res.c.resize(n);
   res.d.resize(n);

   for (int i = 0; i < n; i++) {
     res.a[i] = x[i];
     res.b[i] = y[i];
     res.c[i] = x[i] + 1;
     res.d[i] = y[i] + 1;
   }
   ```
   などとします。
1. `// improve solution` と書いてある部分で解の改善を行います。ただし後述の通りこのテンプレートはある程度改変しても構いません。

このプログラムは以下のように実行されます。この流れは `main.cpp` に既に書かれているので新たに書く必要はありません。

1. `main` 関数で `result` 型のオブジェクトを宣言する
1. `main` 関数がそれを参照渡しで `solve` 関数に渡す
1. `solve` 関数がそこに解を書き込んで `main` 関数に返す
1. `main` 関数が `print` 関数を呼んで解を出力する

# 注意

- デフォルトでは必要最低限のライブラリしか include されていないので、include 文は必要に応じて追加してください。
  ```C++
  #include <bits/stdc++.h>
  using namespace std;
  ```
  をしたい人はしてもよいです。
- `solve` 関数内で標準出力に解を出力するコードを書く必要はありません。求解が終わると `print` 関数が呼ばれて解が出力されるようになっています。
- 求解のプログラムは並列で実行されるので、競合(一つの変数に複数のスレッドが同時に書き込みを行うなど)が発生しないように気をつけてください。
  - 例えば、以下のことは行ってよいです。
    - 関数内でローカル変数を宣言・使用する
    - グローバルに定数を宣言して読み取り専用の値として使用する
    - 内部で状態を保持しない関数 (競技プログラミングで書くような関数の多くはそうです) を作成して使用する
    - `static` 修飾された変数を持たないクラスを作成して使用する
  - 例えば、以下のことは行わないでください。どうしても行う必要がある場合は入力の読み込みのように `safe_invoke` 関数を通して行えばよいですが、テストを並列で実行する際にテスト間で同じ変数が共有されることになるので、プログラムの挙動が想定通りにならない可能性があります。
    - グローバルに変数を宣言し、その変数に書き込みを行う
    - `static` 修飾された変数を用いた関数やクラスを作成して、その変数に書き込みを行う
- このテンプレートはある程度改変して使っても構いませんが、`END_MAINLOOP` や `END_SOLVE_FUNC` を書く位置には気をつけてください。求解を複数のステップに分け、複数のループを回す場合には
  ```C++
  // 実行時間が制限時間の 1/3 になるまで処理 A をする
  while (tm.frac<1, 3>()) {
    // 処理 A
    END_MAINLOOP;
  }

  // 実行時間が制限時間の 2/3 になるまで処理 B をする
  while (tm.frac<2, 3>()) {
    // 処理 B
    END_MAINLOOP;
  }

  // 実行時間が制限時間になるまで処理 C をする
  while (tm.good()) {
    // 処理 C
    END_MAINLOOP;
  }

  END_SOLVE_FUNC;
  ```
  のように `END_MAINLOOP` を複数書くことになる場合があります。`END_SOLVE_FUNC` は常に `solve` 関数の末尾に 1 つだけ書いてください。途中解のスナップショットの取得は `END_MAINLOOP` や `END_SOLVE_FUNC` に到達した時に行われるので、この時に `res` の内容は (0 点でもいいので) 解として正常な状態である必要があります。例えば `END_MAINLOOP` に到達した時に `res` の内容が未初期化である場合には未初期化の変数へのアクセスが発生し未定義動作が起きます。
