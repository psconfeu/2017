using namespace System.Diagnostics
using namespace System.Management.Automation

class ProgressManager {
    [long] $TotalItemCount
    hidden [int] $ActivityId
    hidden [int] $ParentActivityId
    hidden [string] $Activity
    [string] $StatusDescription
    hidden [StopWatch] $Stopwatch

    ProgressManager([string] $activity, [string] $statusDescription, [long] $totalItemCount) {
        $this.init($activity, $StatusDescription, $totalItemCount, 1, - 1)
    }

    ProgressManager([string] $activity, [string] $statusDescription, [long] $totalItemCount, [int] $activityId, [int] $parentActivityId) {
        $this.init($activity, $StatusDescription, $totalItemCount, $activityId, $parentActivityId)
    }

    hidden init([string] $activity, [string] $statusDescription, [long] $totalItemCount, [int] $activityId, [int] $parentActivityId) {
        $this.TotalItemCount = $totalItemCount
        $this.StatusDescription = $statusDescription
        $this.ActivityId = $activityId
        $this.ParentActivityId = $parentActivityId
        $this.Activity = $activity
        $this.Stopwatch = [Stopwatch]::StartNew()
    }

    [ProgressRecord] GetCurrentProgressRecord([long] $currentItemIndex, [string] $currentOperation) {
        $pr = [ProgressRecord]::new($this.ActivityId, $this.Activity, $this.StatusDescription)
        $pr.CurrentOperation = $currentOperation
        $pr.ParentActivityId = $this.ParentActivityId
        $pr.PercentComplete = $this.GetPercentComplete($currentItemIndex)
        $pr.SecondsRemaining = $this.GetSecondsRemaining($currentItemIndex)
        return $pr
    }

    [ProgressRecord] GetCompletedRecord() {
        $pr = [ProgressRecord]::new($this.ActivityId, $this.Activity, $this.StatusDescription)
        $pr.RecordType = [ProgressRecordType]::Completed
        return $pr
    }

    hidden [int] GetSecondsRemaining([long] $currentItemIndex) {
        if ($this.stopwatch.ElapsedMilliseconds -lt 3000) {return -1 }
        if ($currentItemIndex -ge $this.totalItemCount) { return 0 }
        return [int] (($this.totalItemCount - $currentItemIndex) * $this.stopwatch.Elapsed.TotalSeconds / $currentItemIndex)
    }

    hidden [int] GetPercentComplete([long] $currentItemIndex) {
        if ($currentItemIndex -ge $this.totalItemCount) { return 100 }
        return [Math]::Min([int] ($currentItemIndex * 100 / $this.totalItemCount), 100)
    }
}

