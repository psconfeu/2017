
enum Downloadkind {
    WebClient
    IWR
    IWRProgress
}

class WebDownloadResult {
    [Downloadkind] $Kind
    [TimeSpan] $time
    [long] $TimeMs
    [long] $Ticks

    WebDownloadResult([Downloadkind] $Kind, [TimeSpan] $time) {
        $this.Kind = $Kind
        $this.Time = $time
        $this.TimeMs = $time.TotalMilliseconds
        $this.Ticks = $time.Ticks
    }
}
