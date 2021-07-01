using System;

namespace SharePointOnline.Migration.Utilities.Models.Files
{
    public class FileSharePermissionItem
    {
        public FileSharePermissionItem() {}

        public string FolderPath { get; set; }

        public string AdObject { get; set; }

        public string Permissions { get; set; }

        public bool IsInherited { get; set; }
    }
}