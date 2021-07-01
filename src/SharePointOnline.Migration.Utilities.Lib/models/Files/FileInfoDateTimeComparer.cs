using System;
using System.Collections.Generic;
using System.IO;

namespace SharePointOnline.Migration.Utilities.Models.Files
{
    public class FileInfoDateTimeComparer : IComparer<FileInfo>
    {
        public FileInfoDateTimeComparer() { }

        public int Compare(FileInfo item1, FileInfo item2)
        {
            int compareResult = DateTime.Compare(item1.CreationTime, item2.CreationTime);

            return compareResult;
        }
    }
}