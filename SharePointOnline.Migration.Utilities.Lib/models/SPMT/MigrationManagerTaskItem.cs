using System;

namespace SharePointOnline.Migration.Utilities.Models.SPMT
{
    public class MigrationManagerTaskItem
    {
        public MigrationManagerTaskItem() {}

        public string SourcePath { get; set; }

        public string TargetPath { get; set; }

        public string TargetList { get; set; }

        public string TargetListRelativePath { get; set; }
    }
}