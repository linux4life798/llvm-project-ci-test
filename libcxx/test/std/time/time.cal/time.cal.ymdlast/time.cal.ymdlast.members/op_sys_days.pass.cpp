//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// UNSUPPORTED: c++03, c++11, c++14, c++17

// <chrono>
// class year_month_day_last;

// constexpr operator sys_days() const noexcept;
//  Returns: sys_days{year()/month()/day()}.

#include <chrono>
#include <cassert>
#include <type_traits>
#include <utility>

#include "test_macros.h"

int main(int, char**)
{
    using year                = std::chrono::year;
    using month_day_last      = std::chrono::month_day_last;
    using year_month_day_last = std::chrono::year_month_day_last;
    using sys_days            = std::chrono::sys_days;
    using days                = std::chrono::days;

    ASSERT_NOEXCEPT(                    static_cast<sys_days>(std::declval<const year_month_day_last>()));
    ASSERT_SAME_TYPE(sys_days, decltype(static_cast<sys_days>(std::declval<const year_month_day_last>())));

    { // Last day in Jan 1970 was the 31st
    constexpr year_month_day_last ymdl{year{1970}, month_day_last{std::chrono::January}};
    constexpr sys_days sd{ymdl};

    static_assert(sd.time_since_epoch() == days{30}, "");
    }

    {
    constexpr year_month_day_last ymdl{year{2000}, month_day_last{std::chrono::January}};
    constexpr sys_days sd{ymdl};

    static_assert(sd.time_since_epoch() == days{10957+30}, "");
    }

    {
    constexpr year_month_day_last ymdl{year{1940}, month_day_last{std::chrono::January}};
    constexpr sys_days sd{ymdl};

    static_assert(sd.time_since_epoch() == days{-10957+29}, "");
    }

    {
    year_month_day_last ymdl{year{1939}, month_day_last{std::chrono::November}};
    sys_days sd{ymdl};

    assert(sd.time_since_epoch() == days{-(10957+33)});
    }

  return 0;
}
