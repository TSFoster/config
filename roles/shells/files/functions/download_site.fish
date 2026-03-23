function download_site
    set domain $argv[1]
    set level $argv[2]
    set -q argv[2] || set level 5
    wget \
         --recursive \
         --level $level \
         --no-clobber \
         --page-requisites \
         --adjust-extension \
         --span-hosts \
         --convert-links \
         --domains $domain \
         --no-parent \
             $domain
end
