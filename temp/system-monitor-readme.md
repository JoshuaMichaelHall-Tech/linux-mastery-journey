# Linux System Monitor

A terminal-based system monitoring tool built in Python that demonstrates effective use of the Linux environment for software development. This project showcases Python best practices, terminal integration, and system resource monitoring techniques.

![Version](https://img.shields.io/badge/Version-1.0.0-green)
![Python](https://img.shields.io/badge/Python-3.11+-blue)
![License](https://img.shields.io/badge/License-MIT-orange)

## Overview

This system monitor provides real-time visualization of system resources including CPU, memory, disk, and network usage in a terminal interface. The project demonstrates:

- Terminal UI design using Python
- System resource data collection on Linux
- Efficient data visualization
- Clean architecture with separation of concerns
- Modern Python development practices

## Features

- **Real-time System Monitoring**:
  - CPU usage (overall and per-core)
  - Memory and swap usage
  - Disk I/O and space utilization
  - Network traffic (upload/download)
  - Process list with resource usage

- **Visualization Options**:
  - Text-based graphs
  - Percentage indicators
  - Historical data with trends
  - Color-coded alerts for resource thresholds

- **User Interface**:
  - Fully navigable with keyboard
  - Customizable layouts
  - Configurable refresh rates
  - Dark/light themes

- **Data Management**:
  - Logging of resource statistics
  - Export data to CSV
  - Configurable alerts

## Architecture

The project follows a clean architecture pattern with these main components:

1. **Data Collection Layer**: Interfaces with the Linux system to gather resource metrics
2. **Data Processing Layer**: Processes and analyzes the raw metrics
3. **Visualization Layer**: Renders the processed data in the terminal UI
4. **Configuration Layer**: Manages user preferences and settings

## Requirements

- Python 3.11+
- Linux-based operating system (Arch Linux or NixOS recommended)
- Python packages:
  - psutil
  - py-cpuinfo
  - blessed/urwid (for terminal UI)
  - pandas (for data processing)
  - typer (for CLI interface)

## Installation

### Using Poetry (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/linux-system-monitor.git
cd linux-system-monitor

# Install dependencies using Poetry
poetry install

# Run the application
poetry run monitor
```

### Using Pip

```bash
# Clone the repository
git clone https://github.com/yourusername/linux-system-monitor.git
cd linux-system-monitor

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python -m monitor
```

### Using Distribution Packages

#### Arch Linux

```bash
# Install dependencies
sudo pacman -S python python-psutil python-pandas python-blessed

# Clone the repository
git clone https://github.com/yourusername/linux-system-monitor.git
cd linux-system-monitor

# Run the application
python -m monitor
```

#### NixOS

Add the following to your `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  (python311.withPackages(ps: with ps; [
    psutil
    py-cpuinfo
    blessed
    pandas
    typer
  ]))
];
```

Then run:

```bash
# Clone the repository
git clone https://github.com/yourusername/linux-system-monitor.git
cd linux-system-monitor

# Run the application
python -m monitor
```

## Usage

### Basic Usage

```bash
# Start the monitor
python -m monitor

# Start with specific update interval (in seconds)
python -m monitor --interval 2

# Start with specific layout
python -m monitor --layout compact
```

### Keyboard Controls

- `q` - Quit the application
- `h` - Show help screen
- `1-4` - Switch between different views
- `↑/↓` - Navigate process list
- `p` - Sort processes by CPU usage
- `m` - Sort processes by memory usage
- `d` - Sort processes by disk I/O
- `s` - Take a snapshot of current stats
- `c` - Toggle color mode
- `r` - Reset statistics

### Configuration

Configuration is stored in `~/.config/linux-system-monitor/config.toml`:

```toml
[general]
update_interval = 1.0
enable_logging = true
log_path = "~/.local/share/linux-system-monitor/logs"

[display]
theme = "dark"
layout = "detailed"
show_graphs = true
graph_history = 120

[alerts]
cpu_threshold = 90
memory_threshold = 85
disk_threshold = 90
```

## Development

The project structure follows standard Python project conventions:

```
linux-system-monitor/
├── monitor/
│   ├── __init__.py
│   ├── __main__.py
│   ├── collectors/        # Data collection modules
│   ├── processors/        # Data processing modules
│   ├── ui/                # User interface components
│   └── config.py          # Configuration management
├── tests/                 # Unit and integration tests
├── pyproject.toml         # Project metadata and dependencies
├── README.md
└── LICENSE
```

### Development Environment Setup

1. Install development dependencies:

```bash
poetry install --with dev
```

2. Install pre-commit hooks:

```bash
pre-commit install
```

3. Run tests:

```bash
poetry run pytest
```

4. Check code style:

```bash
poetry run black .
poetry run isort .
poetry run flake8
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues to improve the project. To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Run tests to ensure everything works
5. Commit your changes (`git commit -m "Add new feature"`)
6. Push to your branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by Joshua Michael Hall.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The authors or copyright holders shall not be liable for any claim, damages or other liability arising from the use of the software.

This project is a work in progress and may contain bugs or incomplete features. Users are encouraged to report any issues they encounter.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell
