# Reactor.File Usage Rules

This document provides essential guidance for AI coding agents when working with the Reactor.File library.

## Library Overview

Reactor.File is an extension for the Reactor orchestration framework that provides file system operations as declarative steps. It allows you to build workflows that manipulate files, directories, and file metadata in a concurrent, dependency-resolving manner.

## Setup and Configuration

### Installation
```elixir
# In mix.exs
def deps do
  [
    {:reactor_file, "~> 0.18.2"}
  ]
end
```

### Basic Usage Pattern
```elixir
defmodule MyReactor do
  use Reactor, extensions: [Reactor.File]
  
  # Define inputs, steps, and return value
end
```

## Core Principles

### 1. Undoable Operations
Many steps support `revert_on_undo?: true` to restore original state:
- `mkdir_p` - Removes created directories
- `write_file` - Restores original content
- `chmod`, `chown`, `chgrp` - Restore original permissions/ownership

### 2. Error Handling
File operations can fail - always consider error scenarios:
- Missing files/directories
- Permission issues
- Disk space limitations
- Use guards and conditional logic where appropriate

## Step Categories and When to Use

### File Content Operations
- `read_file` - Read entire file content
- `write_file` - Write content to file (supports modes)
- `touch` - Create empty file or update timestamp

### File System Navigation
- `glob` - Find files matching patterns (use for file discovery)
- `stat` / `lstat` - Get file metadata and permissions
- `read_link` - Read symbolic link targets

### Directory Operations  
- `mkdir` - Create single directory
- `mkdir_p` - Create directory with parents (preferred for deep paths)
- `rmdir` - Remove empty directory

### File Management
- `cp` - Copy single file
- `cp_r` - Copy directories recursively
- `rm` - Remove files
- `ln` / `ln_s` - Create hard/symbolic links

### Permissions & Ownership
- `chmod` - Change file permissions
- `chown` - Change file owner
- `chgrp` - Change file group
- `write_stat` - Update file metadata

### Low-Level I/O
- `open_file` / `close_file` - File handle management
- `io_read` / `io_write` - Direct I/O operations
- `io_stream` / `io_binstream` - Streaming operations

## Common Patterns

### File Processing Pipeline
```elixir
# Find files → process each → write results
glob :source_files do
  pattern value("/data/*.csv")
end

map :process_files do
  source result(:source_files)
  
  read_file :content do
    path element(:process_files)
  end
  
  step :transform do
    argument :data, result(:content)
    run &MyModule.process_csv/1
  end
  
  write_file :output do
    path element(:process_files), transform: &String.replace(&1, ".csv", "_processed.csv")
    content result(:transform)
  end
end
```

### Safe File Operations
```elixir
# Always use revert_on_undo for temporary operations
mkdir_p :temp_dir do
  path value("/tmp/my_operation")
  revert_on_undo? true
end

# Preserve metadata when copying
stat :original_stat do
  path input(:source)
end

cp :backup do
  source input(:source)
  destination input(:backup_path)
end

write_stat :preserve_metadata do
  path input(:backup_path)
  stat result(:original_stat)
end
```

### Conditional Operations
```elixir
# Use guards for conditional file operations
read_file :config do
  path value("/etc/app.conf")
end

step :use_config do
  argument :config, result(:config)
  run &parse_config/1
  where config_exists?/1
end

def config_exists?(%{config: _}), do: true
def config_exists?(_), do: false
```

## Best Practices

### 1. Path Handling
- Use `Path.join/2` in transforms for cross-platform compatibility
- Prefer absolute paths for predictable behaviour
- Use `glob` for file discovery rather than hardcoded paths

### 2. Error Prevention
- Check file existence with `stat` before operations
- Use `mkdir_p` instead of `mkdir` for directory creation
- Set `revert_on_undo?: true` for temporary operations

### 3. Resource Management
- Always `close_file` after `open_file`
- Use streaming operations for large files
- Consider memory usage with large file operations

### 4. Security
- Validate file paths to prevent directory traversal
- Use appropriate file permissions (chmod)
- Be cautious with file overwrites

## File Modes Reference

### Common File Modes
- `[:read]` - Read-only access
- `[:write]` - Write access (truncates existing)
- `[:append]` - Append to existing file
- `[:read, :write]` - Read and write access
- `[:write, :exclusive]` - Create new file, fail if exists

### Special Modes
- `:ram` - In-memory file (for open_file)
- `:binary` - Binary mode
- `:compressed` - Enable compression

## Template Transforms

### Common Transform Patterns
```elixir
# Path manipulation
path input(:base_dir), transform: &Path.join(&1, "config.json")

# Extension changes  
path element(:files), transform: &String.replace(&1, ".txt", ".processed")

# Dynamic naming
path value("/tmp"), transform: &Path.join(&1, "backup_#{Date.utc_today()}")
```

## Error Scenarios to Handle

### File System Errors
- File not found
- Permission denied
- Disk full
- Path too long

### Logic Errors
- Attempting to read directories
- Writing to read-only files
- Creating files in non-existent directories

### Recovery Strategies
- Use conditional steps with guards
- Provide fallback values
- Use `revert_on_undo?` for cleanup

## Integration with Other Reactor Extensions

Reactor.File works well with:
- Standard Reactor steps for data transformation
- Map steps for batch file processing
- Debug steps for operation logging
- Compose steps for sub-workflows

## Performance Considerations

- Use streaming operations for large files
- Consider `batch_size` in map steps for many files
- File I/O is inherently synchronous - plan step dependencies accordingly
- Use `async?: false` for steps that must complete before file operations

## Common Pitfalls

1. **Using raw string literals** - Always wrap in `value()`, `input()`, `result()`, or `element()`
2. **Forgetting file handles** - Always close opened files
3. **Path separators** - Use `Path.join/2` for cross-platform compatibility
4. **Overwrite protection** - Consider existing files before writing
5. **Permission inheritance** - New files may not have expected permissions
6. **Temporary files** - Remember to clean up with `revert_on_undo?: true`
