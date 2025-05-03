# Testing Strategy Guide

This guide outlines the testing approaches for projects within the Linux Mastery Journey, using the System Monitor project as a practical example. Following these testing practices will ensure reliable, maintainable code across all projects.

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Test Types and Hierarchy](#test-types-and-hierarchy)
3. [Testing Tools and Frameworks](#testing-tools-and-frameworks)
4. [Test Organization](#test-organization)
5. [Test Data Management](#test-data-management)
6. [Continuous Integration Testing](#continuous-integration-testing)
7. [System Monitor Project Testing](#system-monitor-project-testing)
8. [Cross-Platform Testing](#cross-platform-testing)
9. [Performance Testing](#performance-testing)
10. [Implementing a Testing Workflow](#implementing-a-testing-workflow)

## Testing Philosophy

Our testing approach follows these core principles:

1. **Test-Driven Development**: Write tests before implementing features
2. **Comprehensive Coverage**: Test all critical paths and edge cases
3. **Automation First**: Automate tests wherever possible
4. **Isolation**: Tests should be independent and not affect each other
5. **Readability**: Tests serve as documentation and should be clear
6. **Fast Feedback**: Tests should run quickly to encourage frequent execution
7. **Realistic Conditions**: Tests should mimic real-world usage

## Test Types and Hierarchy

We implement a testing pyramid with the following layers:

### Unit Tests (Foundation)
- Test individual functions and classes in isolation
- Mock external dependencies
- Fast execution (milliseconds)
- High coverage (80%+)

### Integration Tests (Middle)
- Test interactions between components
- Verify correct data flow between modules
- Mock external systems (databases, APIs)
- Medium execution time (seconds)

### System Tests (Top)
- Test the entire application
- End-to-end workflows
- Minimal mocking
- Longer execution time (seconds to minutes)

### Performance Tests (Parallel)
- Measure execution time and resource usage
- Establish baselines and detect regressions
- Run periodically rather than on every commit

## Testing Tools and Frameworks

### Python Projects

#### Core Testing Tools
- **pytest**: Primary testing framework
- **pytest-cov**: Code coverage reporting
- **pytest-mock**: Mocking library
- **pytest-benchmark**: Performance testing

#### Additional Tools
- **tox**: Cross-environment testing
- **hypothesis**: Property-based testing
- **black** + **isort** + **flake8**: Code quality checks
- **mypy**: Static type checking

#### Example Configuration

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
python_classes = Test*
addopts = --verbose --cov=src --cov-report=term-missing
```

### JavaScript/Node.js Projects

#### Core Testing Tools
- **Jest**: Primary testing framework
- **Supertest**: API testing
- **Testing Library**: Component testing

#### Additional Tools
- **ESLint**: Code quality checks
- **Prettier**: Code formatting
- **TypeScript**: Static typing

#### Example Configuration

```json
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!**/node_modules/**',
    '!**/vendor/**'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### Ruby Projects

#### Core Testing Tools
- **RSpec**: Primary testing framework
- **SimpleCov**: Code coverage
- **Factory Bot**: Test object creation
- **VCR**: HTTP request recording and replaying

#### Additional Tools
- **Rubocop**: Code quality checks
- **Sorbet**: Static typing
- **Timecop**: Time manipulation for tests

#### Example Configuration

```ruby
# .rspec
--require spec_helper
--format documentation
--color
```

## Test Organization

Organize tests to mirror the structure of the source code:

```
project/
├── src/
│   ├── module1/
│   │   ├── file1.py
│   │   └── file2.py
│   └── module2/
│       ├── file3.py
│       └── file4.py
└── tests/
    ├── unit/
    │   ├── module1/
    │   │   ├── test_file1.py
    │   │   └── test_file2.py
    │   └── module2/
    │       ├── test_file3.py
    │       └── test_file4.py
    ├── integration/
    │   ├── test_module1_module2.py
    │   └── ...
    └── system/
        ├── test_workflow1.py
        └── ...
```

## Test Data Management

### Principles

1. **Isolated**: Test data should not interfere between tests
2. **Minimal**: Use only the data needed for each test
3. **Realistic**: Test data should represent real-world scenarios
4. **Seeded**: Tests should set up their own data
5. **Teardown**: Tests should clean up after themselves

### Approaches

#### Fixtures

Use fixtures to create reusable test data:

```python
# Python (pytest)
@pytest.fixture
def sample_cpu_data():
    return {
        "usage_percent": 45.3,
        "per_core_percent": [40.1, 50.2, 55.3, 35.4],
        "load_avg": {"1min": 0.95, "5min": 1.05, "15min": 0.85}
    }
```

```javascript
// JavaScript (Jest)
const sampleCpuData = {
  usagePercent: 45.3,
  perCorePercent: [40.1, 50.2, 55.3, 35.4],
  loadAvg: {oneMin: 0.95, fiveMin: 1.05, fifteenMin: 0.85}
};
```

#### Factory Patterns

Use factories for complex test data:

```python
# Python
class ProcessDataFactory:
    @staticmethod
    def create(count=5, high_cpu=False):
        processes = []
        for i in range(count):
            cpu_usage = random.uniform(70, 100) if high_cpu else random.uniform(5, 30)
            processes.append({
                "pid": 1000 + i,
                "name": f"process-{i}",
                "cpu_percent": cpu_usage,
                "memory_percent": random.uniform(5, 30)
            })
        return {"processes": processes}
```

#### Mock External Systems

Use mocks for external dependencies:

```python
# Python
@pytest.fixture
def mock_disk_collector(mocker):
    mock = mocker.patch('monitor.collectors.disk.DiskCollector')
    mock.return_value.collect.return_value = {
        "usage_percent": 65.2,
        "read_speed": 25.6,
        "write_speed": 12.3
    }
    return mock
```

## Continuous Integration Testing

### CI Pipeline Stages

1. **Linting**: Check code style and quality
2. **Static Analysis**: Run type checking and security scans
3. **Unit Tests**: Run all unit tests with coverage
4. **Integration Tests**: Run integration tests
5. **System Tests**: Run system tests
6. **Performance Comparisons**: Compare benchmarks with baseline

### GitHub Actions Configuration

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: 3.11
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -e ".[dev]"
    
    - name: Lint
      run: |
        flake8 src tests
        black --check src tests
        isort --check src tests
    
    - name: Type check
      run: mypy src
    
    - name: Run unit tests
      run: pytest tests/unit
    
    - name: Run integration tests
      run: pytest tests/integration
    
    - name: Run system tests
      run: pytest tests/system
    
    - name: Upload coverage report
      uses: codecov/codecov-action@v3
```

## System Monitor Project Testing

The System Monitor project includes the following testing components:

### Unit Tests

#### Collectors Testing

Test individual data collectors:

```python
# tests/unit/collectors/test_cpu.py
def test_cpu_collector_init():
    collector = CPUCollector()
    assert collector.cpu_count > 0
    assert collector.physical_cores > 0

def test_cpu_collector_collect():
    collector = CPUCollector()
    data = collector.collect()
    
    # Check required fields exist
    assert "usage_percent" in data
    assert "per_core_percent" in data
    assert "load_avg" in data
    
    # Check data validity
    assert 0 <= data["usage_percent"] <= 100
    assert len(data["per_core_percent"]) == collector.cpu_count
    assert all(0 <= x <= 100 for x in data["per_core_percent"])
```

#### Processors Testing

Test data processing components:

```python
# tests/unit/processors/test_resource_processor.py
def test_process_cpu_data():
    processor = ResourceProcessor()
    
    # Test with empty data
    result = processor._process_cpu_data({})
    assert result["usage_percent"] == 0
    assert result["history"] == []
    
    # Test with sample data
    data = {"usage_percent": 50.5, "per_core_percent": [40, 60]}
    result = processor._process_cpu_data(data)
    assert result["usage_percent"] == 50.5
    assert len(result["history"]) == 1
    assert result["history"][0] == 50.5
```

#### UI Components Testing

Test UI rendering components:

```python
# tests/unit/ui/test_dashboard.py
def test_dashboard_init(mock_term, mock_layout_manager, mock_config):
    dashboard = Dashboard(mock_term, mock_layout_manager, mock_config)
    assert dashboard.widgets["cpu"] is not None
    assert dashboard.widgets["memory"] is not None
    assert dashboard.widgets["disk"] is not None
    assert dashboard.widgets["network"] is not None
    assert dashboard.widgets["processes"] is not None
```

### Integration Tests

Test interactions between components:

```python
# tests/integration/test_data_flow.py
def test_collector_to_processor_flow():
    # Set up collectors
    cpu_collector = CPUCollector()
    memory_collector = MemoryCollector()
    
    # Collect data
    cpu_data = cpu_collector.collect()
    memory_data = memory_collector.collect()
    
    # Process data
    processor = ResourceProcessor()
    processed_data = processor.process({
        "cpu": cpu_data,
        "memory": memory_data,
        "timestamp": time.time()
    })
    
    # Verify data flow
    assert "cpu" in processed_data
    assert "memory" in processed_data
    assert processed_data["cpu"]["usage_percent"] == cpu_data["usage_percent"]
    assert processed_data["memory"]["usage_percent"] == memory_data["usage_percent"]
```

### System Tests

Test the entire application:

```python
# tests/system/test_monitor_application.py
def test_application_startup(monkeypatch):
    # Mock terminal input to simulate keypress
    class MockStdin:
        def fileno(self):
            return 0
        
        def read(self):
            return 'q'  # Simulate 'q' key to quit
    
    monkeypatch.setattr('sys.stdin', MockStdin())
    
    # Create a test config
    test_config = Config()
    test_config.general.update_interval = 0.1  # Fast updates for testing
    
    # Run the application with mocked settings
    with pytest.raises(SystemExit) as e:
        main(test_config)
    
    assert e.value.code == 0  # Clean exit
```

### Performance Tests

Benchmark critical components:

```python
# tests/performance/test_collectors_performance.py
def test_cpu_collector_performance(benchmark):
    collector = CPUCollector()
    
    # Benchmark the collect method
    result = benchmark(collector.collect)
    
    # Verify result is valid
    assert "usage_percent" in result
    assert "per_core_percent" in result
```

## Cross-Platform Testing

Test on different Linux distributions:

### Docker-Based Testing

```dockerfile
# dockerfiles/test_arch.Dockerfile
FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm python python-pip

WORKDIR /app
COPY . .
RUN pip install -e ".[dev]"

CMD ["pytest"]
```

```dockerfile
# dockerfiles/test_ubuntu.Dockerfile
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y python3 python3-pip

WORKDIR /app
COPY . .
RUN pip3 install -e ".[dev]"

CMD ["pytest"]
```

### Test Runner Script

```bash
#!/bin/bash
# run_cross_platform_tests.sh

# Build test containers
docker build -t monitor-test-arch -f dockerfiles/test_arch.Dockerfile .
docker build -t monitor-test-ubuntu -f dockerfiles/test_ubuntu.Dockerfile .

# Run tests on Arch Linux
echo "Testing on Arch Linux..."
docker run --rm monitor-test-arch

# Run tests on Ubuntu
echo "Testing on Ubuntu..."
docker run --rm monitor-test-ubuntu
```

## Performance Testing

### Benchmark Suite

```python
# tests/performance/benchmarks.py
import pytest
from monitor.collectors.cpu import CPUCollector
from monitor.collectors.memory import MemoryCollector
from monitor.collectors.disk import DiskCollector
from monitor.collectors.network import NetworkCollector
from monitor.processors.resource_processor import ResourceProcessor

@pytest.mark.benchmark(group="collectors")
def test_cpu_collector_benchmark(benchmark):
    collector = CPUCollector()
    benchmark(collector.collect)

@pytest.mark.benchmark(group="collectors")
def test_memory_collector_benchmark(benchmark):
    collector = MemoryCollector()
    benchmark(collector.collect)

@pytest.mark.benchmark(group="collectors")
def test_disk_collector_benchmark(benchmark):
    collector = DiskCollector()
    benchmark(collector.collect)

@pytest.mark.benchmark(group="collectors")
def test_network_collector_benchmark(benchmark):
    collector = NetworkCollector()
    benchmark(collector.collect)

@pytest.mark.benchmark(group="processors")
def test_resource_processor_benchmark(benchmark):
    processor = ResourceProcessor()
    data = {
        "cpu": CPUCollector().collect(),
        "memory": MemoryCollector().collect(),
        "disk": DiskCollector().collect(),
        "network": NetworkCollector().collect(),
        "timestamp": time.time()
    }
    benchmark(lambda: processor.process(data))
```

### Resource Utilization Tests

```python
# tests/performance/test_resource_usage.py
import resource
import pytest
from monitor.collectors.cpu import CPUCollector

def test_cpu_collector_memory_usage():
    # Get initial memory usage
    initial_memory = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    
    # Create collector and perform operations
    collector = CPUCollector()
    for _ in range(100):
        collector.collect()
    
    # Get final memory usage
    final_memory = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    
    # Calculate memory increase in KB
    memory_increase = final_memory - initial_memory
    
    # Assert reasonable memory usage (adjust threshold as needed)
    assert memory_increase < 5000  # Less than 5MB increase
```

## Implementing a Testing Workflow

### Development Workflow

1. **Write Test First**: Create a failing test that defines the expected behavior
2. **Implement Feature**: Write the minimum code to make the test pass
3. **Refactor**: Improve the implementation while keeping tests passing
4. **Repeat**: Continue the cycle for each feature or bug fix

### Pre-Commit Testing

Set up pre-commit hooks for continuous testing:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run linting
echo "Running linting checks..."
flake8 src tests
if [ $? -ne 0 ]; then
    echo "Linting failed. Fix issues before committing."
    exit 1
fi

# Run unit tests
echo "Running unit tests..."
pytest tests/unit -v
if [ $? -ne 0 ]; then
    echo "Unit tests failed. Fix tests before committing."
    exit 1
fi

# All checks passed
echo "All checks passed!"
exit 0
```

### Regular Performance Testing

Schedule regular performance tests to track trends:

```bash
#!/bin/bash
# run_performance_tests.sh

# Run benchmarks and generate JSON report
pytest tests/performance/benchmarks.py --benchmark-json=benchmark_results.json

# Compare with previous run (if available)
if [ -f benchmark_previous.json ]; then
    pytest-benchmark compare benchmark_previous.json benchmark_results.json --csv=comparison.csv
    
    # Alert on significant regressions
    python scripts/analyze_benchmarks.py comparison.csv
fi

# Save current results for future comparison
cp benchmark_results.json benchmark_previous.json
```

## Conclusion

By implementing this comprehensive testing strategy, we ensure that our Linux Mastery Journey projects remain reliable, maintainable, and performant. The System Monitor project serves as a practical example of these testing principles in action, demonstrating how to test various components of a Linux application effectively.

Each project should adapt these strategies to its specific requirements while maintaining the core principles of the testing philosophy outlined here.

---

> "Master the basics. Then practice them every day without fail." - John C. Maxwell
