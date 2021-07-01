using System;

namespace SharePointOnline.Migration.Utilities.Models.SPMT
{
    public class MigrationManagerTaskItemSettings
    {
        public MigrationManagerTaskItemSettings() {}

        public bool MigrateHiddenItems { get; set; }

        public string MigrateItemsCreatedAfter { get; set; }

        public string MigrateItemsModifiedAfter { get; set; }

        public string SkipFilesWithExtensions { get; set; }

        public bool MigrateOneNoteNotebook { get; set; }
    }
}