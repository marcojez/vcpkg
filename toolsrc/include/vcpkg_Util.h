#pragma once

#include <map>
#include <utility>
#include <vector>

namespace vcpkg::Util
{
    template<class Cont, class Func>
    using FmapOut = decltype(std::declval<Func>()(*begin(std::declval<Cont>())));

    template<class Cont, class Func, class Out = FmapOut<Cont, Func>>
    std::vector<Out> fmap(Cont&& xs, Func&& f)
    {
        using O = decltype(f(*begin(xs)));

        std::vector<O> ret;
        ret.reserve(xs.size());

        for (auto&& x : xs)
            ret.push_back(f(x));

        return ret;
    }

    template<class Container, class Pred>
    void unstable_keep_if(Container& cont, Pred pred)
    {
        cont.erase(std::partition(cont.begin(), cont.end(), pred), cont.end());
    }

    template<class Container, class Pred>
    void erase_remove_if(Container& cont, Pred pred)
    {
        cont.erase(std::remove_if(cont.begin(), cont.end(), pred), cont.end());
    }

    template<class Container, class V>
    auto find(const Container& cont, V&& v)
    {
        return std::find(cont.cbegin(), cont.cend(), v);
    }

    template<class Container, class Pred>
    auto find_if(const Container& cont, Pred pred)
    {
        return std::find_if(cont.cbegin(), cont.cend(), pred);
    }

    template<class Container, class Pred>
    auto find_if_not(const Container& cont, Pred pred)
    {
        return std::find_if_not(cont.cbegin(), cont.cend(), pred);
    }

    template<class K, class V, class Container, class Func>
    void group_by(const Container& cont, std::map<K, std::vector<const V*>>* output, Func f)
    {
        for (const V& element : cont)
        {
            K key = f(element);
            (*output)[key].push_back(&element);
        }
    }

    struct MoveOnlyBase
    {
        MoveOnlyBase() = default;
        MoveOnlyBase(const MoveOnlyBase&) = delete;
        MoveOnlyBase(MoveOnlyBase&&) = default;

        MoveOnlyBase& operator=(const MoveOnlyBase&) = delete;
        MoveOnlyBase& operator=(MoveOnlyBase&&) = default;
    };

    struct ResourceBase
    {
        ResourceBase() = default;
        ResourceBase(const ResourceBase&) = delete;
        ResourceBase(ResourceBase&&) = delete;

        ResourceBase& operator=(const ResourceBase&) = delete;
        ResourceBase& operator=(ResourceBase&&) = delete;
    };
}