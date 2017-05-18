using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.ConstrainedExecution;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Permissions;
using Microsoft.Win32.SafeHandles;
using PowerCode;

namespace PowerCode {
    ///
    /// Original code from wilson8 from CodeProject at url below
    /// https://www.codeproject.com/kb/files/fastdirectoryenumerator.aspx
    /// Slightly modified to
    ///
    /// <summary>
    ///     Contains information about a file returned by the
    ///     <see cref="FastDirectoryEnumerator" /> class.
    /// </summary>
    [Serializable]
    [DebuggerDisplay("{DebuggerDisplay,nq}")]
    public class FileData {
        /// <summary>
        ///     Attributes of the file.
        /// </summary>
        public readonly FileAttributes Attributes;

        /// <summary>
        ///     File creation time in UTC
        /// </summary>
        public readonly DateTime CreationTimeUtc;

        /// <summary>
        ///     File last access time in UTC
        /// </summary>
        public readonly DateTime LastAccessTimeUtc;

        /// <summary>
        ///     File last write time in UTC
        /// </summary>
        public readonly DateTime LastWriteTimeUtc;

        /// <summary>
        ///     Name of the file
        /// </summary>
        public readonly string Name;

        /// <summary>
        ///     Full path to the file.
        /// </summary>
        public readonly string Path;

        /// <summary>
        ///     Size of the file in bytes
        /// </summary>
        public readonly long Size;

        /// <summary>
        ///     Initializes a new instance of the <see cref="FileData" /> class.
        /// </summary>
        /// <param name="dir">The directory that the file is stored at</param>
        /// <param name="findData">
        ///     WIN32_FIND_DATA structure that this
        ///     object wraps.
        /// </param>
        internal FileData(string dir, Win32FindData findData) {
            Attributes = findData.dwFileAttributes;

            CreationTimeUtc = ConvertDateTime(findData.ftCreationTime);
            LastAccessTimeUtc = ConvertDateTime(findData.ftLastAccessTime);
            LastWriteTimeUtc = ConvertDateTime(findData.ftLastWriteTime);

            Size = CombineHighLowInts(findData.nFileSizeHigh, findData.nFileSizeLow);

            Name = findData.cFileName;
            Path = System.IO.Path.Combine(dir, findData.cFileName);
        }

        public DateTime CreationTime => CreationTimeUtc.ToLocalTime();

        /// <summary>
        ///     Gets the last access time in local time.
        /// </summary>
        public DateTime LastAccesTime => LastAccessTimeUtc.ToLocalTime();

        /// <summary>
        ///     Gets the last access time in local time.
        /// </summary>
        public DateTime LastWriteTime => LastWriteTimeUtc.ToLocalTime();

        /// <summary>
        ///     Returns a <see cref="T:System.String" /> that represents the current <see cref="T:System.Object" />.
        /// </summary>
        /// <returns>
        ///     A <see cref="T:System.String" /> that represents the current <see cref="T:System.Object" />.
        /// </returns>
        public override string ToString() => Path;

        private static long CombineHighLowInts(uint high, uint low) => ((long) high << 0x20) | low;

        private static DateTime ConvertDateTime(System.Runtime.InteropServices.ComTypes.FILETIME dateTime) {
            var fileTime = CombineHighLowInts((uint)dateTime.dwHighDateTime, (uint)dateTime.dwLowDateTime);
            return DateTime.FromFileTimeUtc(fileTime);
        }

        private string DebuggerDisplay => $"{Path}";
    }

    /// <summary>
    ///     Contains information about the file that is found
    ///     by the FindFirstFile or FindNextFile functions.
    /// </summary>
    // The CharSet must match the CharSet of the corresponding PInvoke signature
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    class Win32FindData
    {
        public FileAttributes dwFileAttributes;
        public System.Runtime.InteropServices.ComTypes.FILETIME ftCreationTime;
        public System.Runtime.InteropServices.ComTypes.FILETIME ftLastAccessTime;
        public System.Runtime.InteropServices.ComTypes.FILETIME ftLastWriteTime;
        public uint nFileSizeHigh;
        public uint nFileSizeLow;
        public uint dwReserved0;
        public uint dwReserved1;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public string cFileName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 14)]
        public string cAlternateFileName;

    /// <summary>
    ///     Returns a <see cref="T:System.String" /> that represents the current <see cref="T:System.Object" />.
    /// </summary>
    /// <returns>
    ///     A <see cref="T:System.String" /> that represents the current <see cref="T:System.Object" />.
    /// </returns>
    public override string ToString() => cFileName;
    }

    /// <summary>
    ///     A fast enumerator of files in a directory.  Use this if you need to get attributes for
    ///     all files in a directory.
    /// </summary>
    /// <remarks>
    ///     This enumerator is substantially faster than using <see cref="Directory.GetFiles(string)" />
    ///     and then creating a new FileInfo object for each path.  Use this version when you
    ///     will need to look at the attibutes of each file returned (for example, you need
    ///     to check each file in a directory to see if it was modified after a specific date).
    /// </remarks>
    public static class FastDirectoryEnumerator {
        /// <summary>
        ///  Gets <see cref="FileData" /> for all the files in a directory.
        /// </summary>
        /// <param name="path">The path to search.</param>
        /// <returns>
        ///     An object that implements <see cref="IEnumerable{FileData}" /> and
        ///     allows you to enumerate the files in the given directory.
        /// </returns>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="path" /> is a null reference (Nothing in VB)
        /// </exception>
        public static IEnumerable<FileData> EnumerateFiles(string path) => EnumerateFiles(path, "*");

        /// <summary>
        ///     Gets <see cref="FileData" /> for all the files in a directory that match a
        ///     specific filter.
        /// </summary>
        /// <param name="path">The path to search.</param>
        /// <param name="searchPattern">The search string to match against files in the path.</param>
        /// <param name="largeBuffer">request large buffer from IO/Manager</param>
        /// <returns>
        ///     An object that implements <see cref="IEnumerable{FileData}" /> and
        ///     allows you to enumerate the files in the given directory.
        /// </returns>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="path" /> is a null reference (Nothing in VB)
        /// </exception>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="searchPattern" /> is a null reference (Nothing in VB)
        /// </exception>
        public static IEnumerable<FileData> EnumerateFiles(string path, string searchPattern, bool largeBuffer=false) => EnumerateFiles(path, searchPattern, SearchOption.TopDirectoryOnly, largeBuffer);

        /// <summary>
        ///     Gets <see cref="FileData" /> for all the files in a directory that
        ///     match a specific filter, optionally including all sub directories.
        /// </summary>
        /// <param name="path">The path to search.</param>
        /// <param name="searchPattern">The search string to match against files in the path.</param>
        /// <param name="searchOption">
        ///     One of the SearchOption values that specifies whether the search
        ///     operation should include all subdirectories or only the current directory.
        /// </param>
        /// <param name="largeBuffer">request use of larger buffer to filesystem</param>
        /// <returns>
        ///     An object that implements <see cref="IEnumerable{FileData}" /> and
        ///     allows you to enumerate the files in the given directory.
        /// </returns>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="path" /> is a null reference (Nothing in VB)
        /// </exception>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="searchPattern" /> is a null reference (Nothing in VB)
        /// </exception>
        /// <exception cref="ArgumentOutOfRangeException">
        ///     <paramref name="searchOption" /> is not one of the valid values of the
        ///     <see cref="System.IO.SearchOption" /> enumeration.
        /// </exception>
        public static IEnumerable<FileData> EnumerateFiles(string path, string searchPattern, SearchOption searchOption, bool largeBuffer) {
            if (path == null) throw new ArgumentNullException(nameof(path));
            if (searchPattern == null) throw new ArgumentNullException(nameof(searchPattern));
            if (searchOption != SearchOption.TopDirectoryOnly && searchOption != SearchOption.AllDirectories) throw new ArgumentOutOfRangeException(nameof(searchOption));

            var fullPath = Path.GetFullPath(path);

            return new FileEnumerable(fullPath, searchPattern, searchOption, largeBuffer);
        }

        /// <summary>
        ///     Gets <see cref="FileData" /> for all the files in a directory that match a
        ///     specific filter.
        /// </summary>
        /// <param name="path">The path to search.</param>
        /// <param name="searchPattern">The search string to match against files in the path.</param>
        /// <param name="searchOption">recurse or not</param>
        /// <param name="largeBuffer">request use of larger buffer to filesystem</param>
        /// <returns>
        ///     An object that implements <see cref="IEnumerable{FileData}" /> and
        ///     allows you to enumerate the files in the given directory.
        /// </returns>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="path" /> is a null reference (Nothing in VB)
        /// </exception>
        /// <exception cref="ArgumentNullException">
        ///     <paramref name="searchPattern" /> is a null reference (Nothing in VB)
        /// </exception>
        public static FileData[] GetFiles(string path, string searchPattern, SearchOption searchOption, bool largeBuffer = false) {
            var e = EnumerateFiles(path, searchPattern, searchOption, largeBuffer);
            var list = new List<FileData>(200);
            list.AddRange(e);
            return list.ToArray();
        }

        /// <summary>
        ///     Provides the implementation of the
        ///     <see cref="T:System.Collections.Generic.IEnumerable`1" /> interface
        /// </summary>
        private class FileEnumerable : IEnumerable<FileData> {
            private readonly string _filter;
            private readonly string _path;
            private readonly SearchOption _searchOption;
            private readonly bool _largeBuffer;


            /// <summary>
            ///     Initializes a new instance of the <see cref="FileEnumerable" /> class.
            /// </summary>
            /// <param name="path">The path to search.</param>
            /// <param name="filter">The search string to match against files in the path.</param>
            /// <param name="searchOption">
            ///     One of the SearchOption values that specifies whether the search
            ///     operation should include all subdirectories or only the current directory.
            /// </param>
            /// <param name="largeBuffer">corresponds to FIND_FIRST_EX_LARGE_FETCH in FindFirstFileEx</param>
            public FileEnumerable(string path, string filter, SearchOption searchOption, bool largeBuffer) {
                _path = path;
                _filter = filter;
                _searchOption = searchOption;
                _largeBuffer = largeBuffer;
            }

            #region IEnumerable<FileData> Members

            /// <summary>
            ///     Returns an enumerator that iterates through the collection.
            /// </summary>
            /// <returns>
            ///     A <see cref="T:System.Collections.Generic.IEnumerator`1" /> that can
            ///     be used to iterate through the collection.
            /// </returns>
            public IEnumerator<FileData> GetEnumerator() => new FileEnumerator(_path, _filter, _searchOption, _largeBuffer);

            #endregion

            #region IEnumerable Members

            /// <summary>
            ///     Returns an enumerator that iterates through a collection.
            /// </summary>
            /// <returns>
            ///     An <see cref="T:System.Collections.IEnumerator" /> object that can be
            ///     used to iterate through the collection.
            /// </returns>
            IEnumerator IEnumerable.GetEnumerator() => new FileEnumerator(_path, _filter, _searchOption, _largeBuffer);

            #endregion
        }

        /// <summary>
        ///     Wraps a FindFirstFile handle.
        /// </summary>
        private sealed class SafeFindHandle : SafeHandleZeroOrMinusOneIsInvalid {
            /// <summary>
            ///     Initializes a new instance of the <see cref="SafeFindHandle" /> class.
            /// </summary>
            [SecurityPermission(SecurityAction.LinkDemand, UnmanagedCode = true)]
            internal SafeFindHandle()
                : base(true) { }

            [ReliabilityContract(Consistency.WillNotCorruptState, Cer.Success)]
            [DllImport("kernel32.dll")]
            private static extern bool FindClose(IntPtr handle);

            /// <summary>
            ///     When overridden in a derived class, executes the code required to free the handle.
            /// </summary>
            /// <returns>
            ///     true if the handle is released successfully; otherwise, in the
            ///     event of a catastrophic failure, false. In this case, it
            ///     generates a releaseHandleFailed MDA Managed Debugging Assistant.
            /// </returns>
            protected override bool ReleaseHandle() {
                return FindClose(handle);
            }
        }

        /// <summary>
        ///     Provides the implementation of the
        ///     <see cref="T:System.Collections.Generic.IEnumerator`1" /> interface
        /// </summary>
        [SuppressUnmanagedCodeSecurity]
        private class FileEnumerator : IEnumerator<FileData> {
            private const int InfoLevelBasic = 1;
            private readonly Stack<SearchContext> _contextStack;
            private SearchContext _currentContext;
            private readonly string _filter;

            private SafeFindHandle _hndFindFile;

            private string _path;
            private readonly SearchOption _searchOption;
            private readonly bool _largeBuffer;
            private readonly Win32FindData _winFindData = new Win32FindData();

            /// <summary>
            ///     Initializes a new instance of the <see cref="FileEnumerator" /> class.
            /// </summary>
            /// <param name="path">The path to search.</param>
            /// <param name="filter">The search string to match against files in the path.</param>
            /// <param name="searchOption">
            ///     One of the SearchOption values that specifies whether the search
            ///     operation should include all subdirectories or only the current directory.
            /// </param>
            /// <param name="largeBuffer">Use large buffer when fetching data from filesystem</param>
            public FileEnumerator(string path, string filter, SearchOption searchOption, bool largeBuffer) {
                _path = path;
                _filter = filter;
                _searchOption = searchOption;
                _largeBuffer = largeBuffer;
                _currentContext = new SearchContext(path);

                if (_searchOption == SearchOption.AllDirectories)
                    _contextStack = new Stack<SearchContext>();
            }

            #region IEnumerator<FileData> Members

            /// <summary>
            ///     Gets the element in the collection at the current position of the enumerator.
            /// </summary>
            /// <value></value>
            /// <returns>
            ///     The element in the collection at the current position of the enumerator.
            /// </returns>
            public FileData Current => new FileData(_path, _winFindData);

            #endregion

            #region IDisposable Members

            /// <summary>
            ///     Performs application-defined tasks associated with freeing, releasing,
            ///     or resetting unmanaged resources.
            /// </summary>
            public void Dispose() => _hndFindFile?.Dispose();

            #endregion

            [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true, EntryPoint = "FindFirstFileExW")]
            private static extern SafeFindHandle FindFirstFileExW(string fileName, uint infoLevels, [In] [Out] Win32FindData data, uint searchOps, IntPtr searchFilter, uint flags);

            private static SafeFindHandle FindFirstFile(string filename, Win32FindData lpFindFileData, bool largeBuffer) => FindFirstFileExW(filename, InfoLevelBasic, lpFindFileData, 0, IntPtr.Zero, largeBuffer ? 2u : 1u);

            [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true, EntryPoint = "FindNextFile", BestFitMapping = false)]
            private static extern bool FindNextFile(SafeFindHandle hndFindFile, [In] [Out] [MarshalAs(UnmanagedType.LPStruct)] Win32FindData lpFindFileData);

            /// <summary>
            ///     Hold context information about where we current are in the directory search.
            /// </summary>
            private class SearchContext {
                public readonly string Path;
                public Stack<string> SubdirectoriesToProcess;

                public SearchContext(string path) {
                    Path = path;
                }
            }

            #region IEnumerator Members

            /// <summary>
            ///     Gets the element in the collection at the current position of the enumerator.
            /// </summary>
            /// <value></value>
            /// <returns>
            ///     The element in the collection at the current position of the enumerator.
            /// </returns>
            object IEnumerator.Current => new FileData(_path, _winFindData);

            /// <summary>
            ///     Advances the enumerator to the next element of the collection.
            /// </summary>
            /// <returns>
            ///     true if the enumerator was successfully advanced to the next element;
            ///     false if the enumerator has passed the end of the collection.
            /// </returns>
            /// <exception cref="T:System.InvalidOperationException">
            ///     The collection was modified after the enumerator was created.
            /// </exception>
            public bool MoveNext() {
                while (true) {
                    var retval = false;

                    //If the handle is null, this is first call to MoveNext in the current
                    // directory.  In that case, start a new search.
                    if (_currentContext.SubdirectoriesToProcess == null)
                        if (_hndFindFile == null) {

                            var searchPath = Path.Combine(_path, _filter);
                            _hndFindFile = FindFirstFile(searchPath, _winFindData, _largeBuffer);
                            retval = !_hndFindFile.IsInvalid;
                        }
                        else {
                            //Otherwise, find the next item.
                            retval = FindNextFile(_hndFindFile, _winFindData);
                        }

                    //If the call to FindNextFile or FindFirstFile succeeded...
                    if (retval) {
                        if ((_winFindData.dwFileAttributes & FileAttributes.Directory) == FileAttributes.Directory)
                            continue;
                    }
                    else if (_searchOption == SearchOption.AllDirectories) {
                        //SearchContext context = new SearchContext(_hndFindFile, _path);
                        //_contextStack.Push(context);
                        //_path = PathResolve.Combine(_path, _win_find_data.cFileName);
                        //_hndFindFile = null;

                        if (_currentContext.SubdirectoriesToProcess == null) {
                            try {

                                var subDirectories = Directory.GetDirectories(_path);
                                _currentContext.SubdirectoriesToProcess = new Stack<string>(subDirectories);
                            }
                            catch (UnauthorizedAccessException) {
                                _currentContext.SubdirectoriesToProcess = new Stack<string>();
                            }
                        }

                        if (_currentContext.SubdirectoriesToProcess.Count > 0) {
                            var subDir = _currentContext.SubdirectoriesToProcess.Pop();

                            _contextStack.Push(_currentContext);
                            _path = subDir;
                            _hndFindFile = null;
                            _currentContext = new SearchContext(_path);
                            continue;
                        }

                        //If there are no more files in this directory and we are
                        // in a sub directory, pop back up to the parent directory and
                        // continue the search from there.
                        if (_contextStack.Count > 0) {
                            _currentContext = _contextStack.Pop();
                            _path = _currentContext.Path;
                            if (_hndFindFile != null) {
                                _hndFindFile.Close();
                                _hndFindFile = null;
                            }

                            continue;
                        }
                    }

                    return retval;
                }
            }

            /// <summary>
            ///     Sets the enumerator to its initial position, which is before the first element in the collection.
            /// </summary>
            /// <exception cref="T:System.InvalidOperationException">
            ///     The collection was modified after the enumerator was created.
            /// </exception>
            public void Reset() => _hndFindFile = null;

            #endregion
        }
    }
}