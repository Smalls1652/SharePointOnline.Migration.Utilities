using System;

namespace SharePointOnline.Migration.Utilities.Models.ActiveDirectory
{
    public class ActiveDirectoryGroup
    {
        public ActiveDirectoryGroup() {}

        public string Group { get; set; }

        public string[] GroupMembers { get; set; }

        public string[] RecursiveGroupMembers { get; set; }

        public bool HasNestedGroups { get; set; }

        public ActiveDirectoryGroup[] NestedGroups { get; set; }
    }
}