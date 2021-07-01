using System;
using System.Management.Automation;

namespace SharePointOnline.Migration.Utilities.Models.SPMT
{
    public class ReportItem
    {
        public ReportItem() { }

        public ReportItem(PSObject inputItem)
        {
            DestinationPath = GetObjectValue(inputItem, "Destination");
            DestinationItemId = GetObjectValue(inputItem, "Destination item ID");
            MigrationAgentName = GetObjectValue(inputItem, "Device name");
            ErrorCode = GetObjectValue(inputItem, "Error code");
            Extension = GetObjectValue(inputItem, "Extension");
            IncrementalRound = GetObjectValue(inputItem, "Incremental round");
            ItemName = GetObjectValue(inputItem, "Item name");
            ItemSizeInGB = GetItemSize(inputItem);
            Message = GetObjectValue(inputItem, "Message");
            MigrationJobId = GetObjectValue(inputItem, "Migration job ID");
            PackageNumber = GetObjectValue(inputItem, "Package number");
            ResultCategory = GetObjectValue(inputItem, "Result category");
            ServerErrorMessage = GetObjectValue(inputItem, "Server error message");
            SourcePath = GetObjectValue(inputItem, "Source");
            SourceItemId = GetObjectValue(inputItem, "Source item ID");
            Status = GetObjectValue(inputItem, "Status");
            TaskId = GetObjectValue(inputItem, "Task ID");
            Type = GetObjectValue(inputItem, "Type");
        }

        public string DestinationPath { get; set; }
        public string DestinationItemId { get; set; }
        public string MigrationAgentName { get; set; }
        public string ErrorCode { get; set; }
        public string Extension { get; set; }
        public string IncrementalRound { get; set; }
        public string ItemName { get; set; }
        public decimal ItemSizeInGB { get; set; }
        public string Message { get; set; }
        public string MigrationJobId { get; set; }
        public string PackageNumber { get; set; }
        public string ResultCategory { get; set; }
        public string ServerErrorMessage { get; set; }
        public string SourcePath { get; set; }
        public string SourceItemId { get; set; }
        public string Status { get; set; }
        public string TaskId { get; set; }
        public string Type { get; set; }

        private string GetObjectValue(PSObject input, string propertyName)
        {
            string objVal;

            try
            {
                objVal = input.Properties[propertyName].Value.ToString();
            }
            catch (NullReferenceException)
            {
                objVal = null;
            }

            return objVal;
        }

        private decimal GetItemSize(PSObject input)
        {
            decimal itemSizeBytes = Convert.ToDecimal(GetObjectValue(input, "Item size (bytes)"));

            decimal itemSize = Math.Round((itemSizeBytes / 1073741824), 2);

            return itemSize;
        }
    }
}