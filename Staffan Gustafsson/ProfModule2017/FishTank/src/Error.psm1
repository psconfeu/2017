using namespace System.Management.Automation

class Error {
    static [ErrorRecord] UnsupportedFileFormat([string] $path) {
        $x = [System.ArgumentException]::new("The path '$path' does not have the required extension '.ftk'")
        return [ErrorRecord]::new($x, "InvalidFileFormat", [ErrorCategory]::InvalidArgument, $path)
    }

    static [ErrorRecord] CannotFindFishTankModel([string] $modelName) {
        $x = [System.ArgumentException]::new("The model '$modelName' does not exist")
        return [ErrorRecord]::new($x, "FishTankModelNotFound", [ErrorCategory]::ObjectNotFound, $modelName)
    }

    static [ErrorRecord] CannotFindFishTankId([int] $Id) {
        $x = [System.ArgumentException]::new("The fishtank with id '$id' does not exist")
        return [ErrorRecord]::new($x, "FishTankIdNotFound", [ErrorCategory]::ObjectNotFound, $Id)
    }
}
