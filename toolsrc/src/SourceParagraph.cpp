#include "pch.h"

#include "SourceParagraph.h"
#include "Triplet.h"
#include "vcpkg_Checks.h"
#include "vcpkg_Maps.h"
#include "vcpkg_System.h"
#include "vcpkg_Util.h"
#include "vcpkg_expected.h"

namespace vcpkg
{
    using namespace vcpkg::Parse;

    bool g_feature_packages = false;
    namespace Fields
    {
        static const std::string BUILD_DEPENDS = "Build-Depends";
        static const std::string DEFAULTFEATURES = "Default-Features";
        static const std::string DESCRIPTION = "Description";
        static const std::string FEATURE = "Feature";
        static const std::string MAINTAINER = "Maintainer";
        static const std::string SOURCE = "Source";
        static const std::string SUPPORTS = "Supports";
        static const std::string VERSION = "Version";
    }

    static span<const std::string> get_list_of_valid_fields()
    {
        static const std::string valid_fields[] = {
            Fields::SOURCE, Fields::VERSION, Fields::DESCRIPTION, Fields::MAINTAINER, Fields::BUILD_DEPENDS,
        };

        return valid_fields;
    }

    void print_error_message(span<const std::unique_ptr<Parse::ParseControlErrorInfo>> error_info_list)
    {
        Checks::check_exit(VCPKG_LINE_INFO, error_info_list.size() > 0);

        for (auto&& error_info : error_info_list)
        {
            Checks::check_exit(VCPKG_LINE_INFO, error_info != nullptr);
            if (error_info->error)
            {
                System::println(
                    System::Color::error, "Error: while loading %s: %s", error_info->name, error_info->error.message());
            }
        }

        bool have_remaining_fields = false;
        for (auto&& error_info : error_info_list)
        {
            if (!error_info->extra_fields.empty())
            {
                System::println(System::Color::error,
                                "Error: There are invalid fields in the control file of %s",
                                error_info->name);
                System::println("The following fields were not expected:\n\n    %s\n",
                                Strings::join("\n    ", error_info->extra_fields));
                have_remaining_fields = true;
            }
        }

        if (have_remaining_fields)
        {
            System::println("This is the list of valid fields (case-sensitive): \n\n    %s\n",
                            Strings::join("\n    ", get_list_of_valid_fields()));
            System::println("Different source may be available for vcpkg. Use .\\bootstrap-vcpkg.bat to update.\n");
        }

        for (auto&& error_info : error_info_list)
        {
            if (!error_info->missing_fields.empty())
            {
                System::println(System::Color::error,
                                "Error: There are missing fields in the control file of %s",
                                error_info->name);
                System::println("The following fields were missing:\n\n    %s\n",
                                Strings::join("\n    ", error_info->missing_fields));
            }
        }
    }

    static ParseExpected<SourceParagraph> parse_source_paragraph(RawParagraph&& fields)
    {
        ParagraphParser parser(std::move(fields));

        auto spgh = std::make_unique<SourceParagraph>();

        parser.required_field(Fields::SOURCE, spgh->name);
        parser.required_field(Fields::VERSION, spgh->version);

        spgh->description = parser.optional_field(Fields::DESCRIPTION);
        spgh->maintainer = parser.optional_field(Fields::MAINTAINER);
        spgh->depends = expand_qualified_dependencies(parse_comma_list(parser.optional_field(Fields::BUILD_DEPENDS)));
        spgh->supports = parse_comma_list(parser.optional_field(Fields::SUPPORTS));
        spgh->default_features = parse_comma_list(parser.optional_field(Fields::DEFAULTFEATURES));

        auto err = parser.error_info(spgh->name);
        if (err)
            return std::move(err);
        else
            return std::move(spgh);
    }

    static ParseExpected<FeatureParagraph> parse_feature_paragraph(RawParagraph&& fields)
    {
        ParagraphParser parser(std::move(fields));

        auto fpgh = std::make_unique<FeatureParagraph>();

        parser.required_field(Fields::FEATURE, fpgh->name);
        parser.required_field(Fields::DESCRIPTION, fpgh->description);

        fpgh->depends = expand_qualified_dependencies(parse_comma_list(parser.optional_field(Fields::BUILD_DEPENDS)));

        auto err = parser.error_info(fpgh->name);
        if (err)
            return std::move(err);
        else
            return std::move(fpgh);
    }

    ParseExpected<SourceControlFile> SourceControlFile::parse_control_file(
        std::vector<std::unordered_map<std::string, std::string>>&& control_paragraphs)
    {
        if (control_paragraphs.size() == 0)
        {
            return std::make_unique<Parse::ParseControlErrorInfo>();
        }

        auto control_file = std::make_unique<SourceControlFile>();

        auto maybe_source = parse_source_paragraph(std::move(control_paragraphs.front()));
        if (auto source = maybe_source.get())
            control_file->core_paragraph = std::move(*source);
        else
            return std::move(maybe_source).error();

        control_paragraphs.erase(control_paragraphs.begin());

        for (auto&& feature_pgh : control_paragraphs)
        {
            auto maybe_feature = parse_feature_paragraph(std::move(feature_pgh));
            if (auto feature = maybe_feature.get())
                control_file->feature_paragraphs.emplace_back(std::move(*feature));
            else
                return std::move(maybe_feature).error();
        }

        return std::move(control_file);
    }

    std::vector<Dependency> vcpkg::expand_qualified_dependencies(const std::vector<std::string>& depends)
    {
        return Util::fmap(depends, [&](const std::string& depend_string) -> Dependency {
            auto pos = depend_string.find(' ');
            if (pos == std::string::npos) return {depend_string, ""};
            // expect of the form "\w+ \[\w+\]"
            Dependency dep;
            dep.name = depend_string.substr(0, pos);
            if (depend_string.c_str()[pos + 1] != '[' || depend_string[depend_string.size() - 1] != ']')
            {
                // Error, but for now just slurp the entire string.
                return {depend_string, ""};
            }
            dep.qualifier = depend_string.substr(pos + 2, depend_string.size() - pos - 3);
            return dep;
        });
    }

    std::vector<std::string> parse_comma_list(const std::string& str)
    {
        if (str.empty())
        {
            return {};
        }

        std::vector<std::string> out;

        size_t cur = 0;
        do
        {
            auto pos = str.find(',', cur);
            if (pos == std::string::npos)
            {
                out.push_back(str.substr(cur));
                break;
            }
            out.push_back(str.substr(cur, pos - cur));

            // skip comma and space
            ++pos;
            if (str[pos] == ' ')
            {
                ++pos;
            }

            cur = pos;
        } while (cur != std::string::npos);

        return out;
    }

    std::vector<std::string> filter_dependencies(const std::vector<vcpkg::Dependency>& deps, const Triplet& t)
    {
        std::vector<std::string> ret;
        for (auto&& dep : deps)
        {
            if (dep.qualifier.empty() || t.canonical_name().find(dep.qualifier) != std::string::npos)
            {
                ret.push_back(dep.name);
            }
        }
        return ret;
    }

    const std::string& to_string(const Dependency& dep) { return dep.name; }

    ExpectedT<Supports, std::vector<std::string>> Supports::parse(const std::vector<std::string>& strs)
    {
        Supports ret;
        std::vector<std::string> unrecognized;

        for (auto&& str : strs)
        {
            if (str == "x64")
                ret.architectures.push_back(Architecture::X64);
            else if (str == "x86")
                ret.architectures.push_back(Architecture::X86);
            else if (str == "arm")
                ret.architectures.push_back(Architecture::ARM);
            else if (str == "windows")
                ret.platforms.push_back(Platform::WINDOWS);
            else if (str == "uwp")
                ret.platforms.push_back(Platform::UWP);
            else if (str == "v140")
                ret.toolsets.push_back(ToolsetVersion::V140);
            else if (str == "v141")
                ret.toolsets.push_back(ToolsetVersion::V141);
            else if (str == "crt-static")
                ret.crt_linkages.push_back(Linkage::STATIC);
            else if (str == "crt-dynamic")
                ret.crt_linkages.push_back(Linkage::DYNAMIC);
            else
                unrecognized.push_back(str);
        }

        if (unrecognized.empty())
            return std::move(ret);
        else
            return std::move(unrecognized);
    }

    bool Supports::is_supported(Architecture arch, Platform plat, Linkage crt, ToolsetVersion tools)
    {
        auto is_in_or_empty = [](auto v, auto&& c) -> bool { return c.empty() || c.end() != Util::find(c, v); };
        if (!is_in_or_empty(arch, architectures)) return false;
        if (!is_in_or_empty(plat, platforms)) return false;
        if (!is_in_or_empty(crt, crt_linkages)) return false;
        if (!is_in_or_empty(tools, toolsets)) return false;
        return true;
    }
}
