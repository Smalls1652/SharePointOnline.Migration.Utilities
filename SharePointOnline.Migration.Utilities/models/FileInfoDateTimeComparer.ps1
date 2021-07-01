using namespace System.Collections.Generic
using namespace System.IO

class FileInfoDateTimeComparer : IComparer[FileInfo] {

    FileInfoDateTimeComparer() { }

    [int]Compare ([FileInfo]$item1, [FileInfo]$item2) {
        $compareResult = [System.DateTime]::Compare($item1.CreationTime, $item2.CreationTime)

        return $compareResult
    }
}