#pragma region template
#include <chrono>
#include <iostream>

#ifdef PARALLEL
#include <algorithm>
#include <array>
#include <bitset>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <string>
#include <string_view>
#include <thread>

namespace parallel {
  std::mutex mtx;
}

template <class Func> void safe_invoke(const Func& f) {
  std::lock_guard lock(parallel::mtx);
  f();
}
#else
template <class Func> void safe_invoke(const Func& f) {
  f();
}
#endif  // PARALLEL

#ifdef SNAPSHOT
#include <cassert>
#include <condition_variable>
#include <fstream>
#include <mutex>
#include <string>
#include <thread>

namespace snapshot {
  std::mutex mtx;
  std::condition_variable cv;
  bool is_paused = false, is_finished = false;
}  // namespace snapshot

#define END_MAINLOOP                                                                          \
  do {                                                                                        \
    {                                                                                         \
      std::lock_guard lock(snapshot::mtx);                                                    \
      snapshot::is_paused = true;                                                             \
    }                                                                                         \
    snapshot::cv.notify_one();                                                                \
    std::unique_lock lock(snapshot::mtx);                                                     \
    snapshot::cv.wait(lock, [&] { return (!snapshot::is_paused) || snapshot::is_finished; }); \
  } while (false)

#define END_SOLVE_FUNC                     \
  do {                                     \
    {                                      \
      std::lock_guard lock(snapshot::mtx); \
      snapshot::is_finished = true;        \
    }                                      \
    snapshot::cv.notify_one();             \
  } while (false)
#else
#define END_MAINLOOP (static_cast<void>(0))
#define END_SOLVE_FUNC (static_cast<void>(0))
#endif  // SNAPSHOT
#pragma endregion

namespace utility {
  struct timer {
    private:
    const std::chrono::system_clock::time_point start;

    public:
    static constexpr unsigned time_limit = 2000 - 20;

    timer() noexcept : start(std::chrono::system_clock::now()) {}

    [[nodiscard]] auto elapsed() const {
      using namespace std::chrono;
      return duration_cast<milliseconds>(system_clock::now() - start).count();
    }
    template <unsigned num, unsigned den>[[nodiscard]] bool frac() const {
      return elapsed() < time_limit * num / den;
    }
    [[nodiscard]] bool good() const {
      return elapsed() < time_limit;
    }
  };
}  // namespace utility

struct result {
};

void print(std::ostream& os, const result& res) {
}

void solve(std::istream& is, result& res) {
  const utility::timer tm;

  // declare variables
  // int N, ...;

  const auto scan = [&] {
    // read inputs
    // is >> N >> ...;
  };
  safe_invoke(scan);

  // initialize solution

  while (tm.good()) {
    // improve solution
    END_MAINLOOP;
  }

  END_SOLVE_FUNC;
}

int main() {
#ifdef PARALLEL
  constexpr std::string_view TEST_IN_DIR = "test/in/";
  const std::string TEST_OUT_DIR         = "test/out/";

  constexpr unsigned threads = 15;

  const auto tests = std::count_if(std::filesystem::directory_iterator(TEST_IN_DIR),
                                   std::filesystem::directory_iterator {},
                                   [](const auto& file) { return file.path().extension() == ".txt"; });

  auto it = std::filesystem::directory_iterator(TEST_IN_DIR);

  unsigned started = 0, finished = 0;

  std::array<std::thread, threads> jobs;
  std::array<std::ifstream, threads> ifs;
  std::array<std::ofstream, threads> ofs;
  std::array<result, threads> res;

  std::bitset<threads> running;

  const auto show_progress = [&, bar_length = 50u, &os = std::cerr] {
    std::lock_guard lock(parallel::mtx);
    const auto bar_top = bar_length * finished / tests;
    os << "[\033[92m";
    for (unsigned j = 0; j < bar_length; ++j)
      os << (j <= bar_top ? '#' : ' ');
    os << "\033[39m] " << (100 * bar_top / bar_length) << "% (" << finished << '/' << tests << ')';
    if (tests == finished)
      os << std::endl;
    else
      os << '\r' << std::flush;
  };

  show_progress();

  while (finished < tests) {
    for (unsigned i = 0; i < threads; ++i) {
      if (!running[i] && started < tests) {
        std::lock_guard lock(parallel::mtx);
        while ((*it).path().extension() != ".txt")
          ++it;
        ifs[i]  = std::ifstream((*it).path());
        ofs[i]  = std::ofstream(TEST_OUT_DIR + (*it).path().filename().string());
        res[i]  = result {};
        jobs[i] = std::thread(solve, std::ref(ifs[i]), std::ref(res[i]));
        ++started;
        running[i] = true;
        ++it;
      } else if (running[i]) {
        jobs[i].join();
        ++finished;
        running[i] = false;
        safe_invoke([&] { print(ofs[i], res[i]); });
        show_progress();
      }
    }
  }
#elif defined SNAPSHOT
  std::ios_base::sync_with_stdio(false);
  std::cin.tie(nullptr);

  const auto pad_zeros = [](const unsigned i) {
    assert(i <= 9999u);
    std::string s = "000" + std::to_string(i);
    return s.substr(std::size(s) - 4);
  };

  result res;
  std::thread job(solve, std::ref(std::cin), std::ref(res));

  const std::string SNAPSHOT_OUT_DIR = "test/snapshot/";

  unsigned file_num = 0;

  const utility::timer tm;
  std::chrono::system_clock::time_point prev_snapshot_time {};

  while (tm.good()) {
    {
      std::unique_lock lock(snapshot::mtx);
      snapshot::cv.wait(lock, [&] { return snapshot::is_paused || snapshot::is_finished; });

      auto current_time = std::chrono::system_clock::now();

      if (std::chrono::duration_cast<std::chrono::milliseconds>(current_time - prev_snapshot_time).count() >= 10) {
        std::ofstream ofs(SNAPSHOT_OUT_DIR + pad_zeros(file_num) + ".txt");
        print(ofs, res);
        ++file_num;
        prev_snapshot_time = current_time;
      }
      snapshot::is_paused = false;
    }
    snapshot::cv.notify_one();
  }

  {
    std::lock_guard lock(snapshot::mtx);
    snapshot::is_finished = true;
  }
  snapshot::cv.notify_one();

  job.join();
#else
  std::ios_base::sync_with_stdio(false);
  std::cin.tie(nullptr);

  result res;
  solve(std::cin, res);
  print(std::cout, res);
#endif
}
