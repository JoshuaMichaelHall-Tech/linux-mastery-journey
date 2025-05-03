import React, { useState, useEffect } from 'react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  BarChart, Bar, PieChart, Pie, Cell
} from 'recharts';

// Sample data for demonstration
const generateData = () => {
  const now = new Date();
  return {
    cpu: {
      usage_percent: Math.floor(Math.random() * 40) + 30,
      per_core_percent: [
        Math.floor(Math.random() * 50) + 30,
        Math.floor(Math.random() * 50) + 20,
        Math.floor(Math.random() * 50) + 10,
        Math.floor(Math.random() * 50) + 15
      ],
      temperature: Math.floor(Math.random() * 20) + 50,
      history: Array(30).fill().map((_, i) => ({
        time: new Date(now.getTime() - (29 - i) * 5000).toLocaleTimeString(),
        value: Math.floor(Math.random() * 40) + 10
      }))
    },
    memory: {
      usage_percent: Math.floor(Math.random() * 30) + 40,
      used: 6.2,
      total: 15.8,
      history: Array(30).fill().map((_, i) => ({
        time: new Date(now.getTime() - (29 - i) * 5000).toLocaleTimeString(),
        value: Math.floor(Math.random() * 30) + 30
      }))
    },
    disk: {
      usage_percent: Math.floor(Math.random() * 20) + 30,
      read_speed: Math.random() * 15,
      write_speed: Math.random() * 8,
      partitions: [
        { name: '/', total: 128, used: 42 },
        { name: '/home', total: 324, used: 156 },
        { name: '/var', total: 64, used: 28 }
      ],
      history: Array(30).fill().map((_, i) => ({
        time: new Date(now.getTime() - (29 - i) * 5000).toLocaleTimeString(),
        read: Math.random() * 15,
        write: Math.random() * 8
      }))
    },
    network: {
      download_speed: Math.random() * 5,
      upload_speed: Math.random() * 2,
      interfaces: [
        { name: 'eth0', state: 'up', ip: '192.168.1.100' },
        { name: 'wlan0', state: 'down', ip: null }
      ],
      history: Array(30).fill().map((_, i) => ({
        time: new Date(now.getTime() - (29 - i) * 5000).toLocaleTimeString(),
        download: Math.random() * 5,
        upload: Math.random() * 2
      }))
    },
    processes: {
      total: 124,
      running: 3,
      sleeping: 121,
      list: [
        { pid: 1, name: 'systemd', cpu: 0.2, memory: 1.5 },
        { pid: 1293, name: 'firefox', cpu: 8.5, memory: 12.6 },
        { pid: 1820, name: 'neovim', cpu: 2.3, memory: 3.8 },
        { pid: 2145, name: 'python', cpu: 14.2, memory: 5.2 },
        { pid: 3012, name: 'node', cpu: 6.7, memory: 8.4 }
      ]
    }
  };
};

const UsageBar = ({ value, color }) => {
  const displayColor = value > 90 ? 'bg-red-500' : 
                        value > 70 ? 'bg-yellow-500' : 
                        color;
  
  return (
    <div className="w-full bg-gray-200 rounded-full h-4 mb-2">
      <div 
        className={`${displayColor} h-4 rounded-full`} 
        style={{ width: `${value}%` }}
      >
      </div>
    </div>
  );
};

const IconLabel = ({ children, icon, color }) => {
  return (
    <div className="flex items-center">
      <div className={`mr-2 ${color} w-6 h-6 flex items-center justify-center rounded-full`}>
        {icon}
      </div>
      <span className="font-bold">{children}</span>
    </div>
  );
};

const SystemMonitor = () => {
  const [data, setData] = useState(generateData());
  const [refreshInterval, setRefreshInterval] = useState(5);
  const [theme, setTheme] = useState('dark');
  
  useEffect(() => {
    const interval = setInterval(() => {
      setData(generateData());
    }, refreshInterval * 1000);
    
    return () => clearInterval(interval);
  }, [refreshInterval]);
  
  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];
  
  return (
    <div className={`p-4 ${theme === 'dark' ? 'bg-gray-900 text-white' : 'bg-white text-gray-800'}`}>
      {/* Header */}
      <header className="flex items-center justify-between mb-6 border-b pb-4 border-gray-700">
        <div className="flex items-center">
          <div className="mr-2 text-blue-500 text-2xl">📊</div>
          <h1 className="text-2xl font-bold">Linux System Monitor</h1>
        </div>
        <div className="flex items-center space-x-4">
          <div className="flex items-center">
            <span className="mr-2">Refresh:</span>
            <select 
              value={refreshInterval}
              onChange={(e) => setRefreshInterval(parseInt(e.target.value))}
              className="bg-gray-800 text-white p-1 rounded"
            >
              <option value="1">1s</option>
              <option value="5">5s</option>
              <option value="10">10s</option>
            </select>
          </div>
          <button 
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className="p-2 rounded hover:bg-gray-700"
          >
            ⚙️
          </button>
          <button 
            onClick={() => setData(generateData())}
            className="p-2 rounded hover:bg-gray-700"
          >
            🔄
          </button>
        </div>
      </header>
      
      {/* Main Grid */}
      <div className="grid grid-cols-2 gap-4 mb-4">
        {/* CPU Widget */}
        <div className={`p-4 rounded-lg ${theme === 'dark' ? 'bg-gray-800' : 'bg-gray-100'}`}>
          <div className="flex items-center justify-between mb-4">
            <IconLabel icon="🧠" color="bg-blue-500">
              CPU Usage
            </IconLabel>
            <div className="flex items-center">
              <span className="mr-1">🌡️</span>
              <span>{data.cpu.temperature}°C</span>
            </div>
          </div>
          
          <div className="flex items-center mb-2">
            <span className="text-2xl font-bold mr-2">{data.cpu.usage_percent}%</span>
            <UsageBar value={data.cpu.usage_percent} color="bg-blue-500" />
          </div>
          
          <div className="mb-4">
            <h3 className="text-sm text-gray-500 mb-2">Per Core Usage</h3>
            <div className="grid grid-cols-4 gap-2">
              {data.cpu.per_core_percent.map((usage, i) => (
                <div key={i} className="text-center">
                  <div className="text-sm mb-1">Core {i+1}</div>
                  <UsageBar value={usage} color="bg-blue-400" />
                  <div className="text-sm">{usage}%</div>
                </div>
              ))}
            </div>
          </div>
          
          <div className="h-40">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.cpu.history}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" tick={false} />
                <YAxis domain={[0, 100]} />
                <Tooltip />
                <Line 
                  type="monotone" 
                  dataKey="value" 
                  stroke="#3b82f6" 
                  strokeWidth={2} 
                  dot={false} 
                  name="CPU Usage %" 
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
        
        {/* Memory Widget */}
        <div className={`p-4 rounded-lg ${theme === 'dark' ? 'bg-gray-800' : 'bg-gray-100'}`}>
          <div className="flex items-center mb-4">
            <IconLabel icon="🧩" color="bg-green-500">
              Memory Usage
            </IconLabel>
          </div>
          
          <div className="flex items-center mb-2">
            <span className="text-2xl font-bold mr-2">{data.memory.usage_percent}%</span>
            <UsageBar value={data.memory.usage_percent} color="bg-green-500" />
          </div>
          
          <div className="flex justify-between mb-4">
            <div>
              <span className="text-gray-500">Used:</span> {data.memory.used} GB
            </div>
            <div>
              <span className="text-gray-500">Total:</span> {data.memory.total} GB
            </div>
            <div>
              <span className="text-gray-500">Free:</span> {(data.memory.total - data.memory.used).toFixed(1)} GB
            </div>
          </div>
          
          <div className="h-40">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.memory.history}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" tick={false} />
                <YAxis domain={[0, 100]} />
                <Tooltip />
                <Line 
                  type="monotone" 
                  dataKey="value" 
                  stroke="#22c55e" 
                  strokeWidth={2} 
                  dot={false} 
                  name="Memory Usage %" 
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
        
        {/* Disk Widget */}
        <div className={`p-4 rounded-lg ${theme === 'dark' ? 'bg-gray-800' : 'bg-gray-100'}`}>
          <div className="flex items-center mb-4">
            <IconLabel icon="💽" color="bg-yellow-500">
              Disk Usage
            </IconLabel>
          </div>
          
          <div className="flex items-center mb-2">
            <span className="text-2xl font-bold mr-2">{data.disk.usage_percent}%</span>
            <UsageBar value={data.disk.usage_percent} color="bg-yellow-500" />
          </div>
          
          <div className="flex justify-between mb-4">
            <div>
              <span className="text-gray-500">Read:</span> {data.disk.read_speed.toFixed(1)} MB/s
            </div>
            <div>
              <span className="text-gray-500">Write:</span> {data.disk.write_speed.toFixed(1)} MB/s
            </div>
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div className="h-40">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={data.disk.partitions}
                    dataKey="used"
                    nameKey="name"
                    cx="50%"
                    cy="50%"
                    outerRadius={60}
                    label={({ name }) => name}
                  >
                    {data.disk.partitions.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value) => `${value} GB`} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="h-40">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data.disk.history.slice(-10)}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="time" tick={false} />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="read" fill="#eab308" name="Read MB/s" />
                  <Bar dataKey="write" fill="#f59e0b" name="Write MB/s" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
        
        {/* Network Widget */}
        <div className={`p-4 rounded-lg ${theme === 'dark' ? 'bg-gray-800' : 'bg-gray-100'}`}>
          <div className="flex items-center mb-4">
            <IconLabel icon="📡" color="bg-purple-500">
              Network Activity
            </IconLabel>
          </div>
          
          <div className="flex justify-between mb-4">
            <div className="flex items-center">
              <span className="mr-1">⬇️</span>
              <span className="text-gray-500 mr-1">Download:</span> {data.network.download_speed.toFixed(2)} MB/s
            </div>
            <div className="flex items-center">
              <span className="mr-1">⬆️</span>
              <span className="text-gray-500 mr-1">Upload:</span> {data.network.upload_speed.toFixed(2)} MB/s
            </div>
          </div>
          
          <div className="mb-4">
            <h3 className="text-sm text-gray-500 mb-2">Interfaces</h3>
            <div className="grid grid-cols-2 gap-2">
              {data.network.interfaces.map((iface, i) => (
                <div key={i} className={`p-2 rounded ${iface.state === 'up' ? 'bg-green-900 bg-opacity-20' : 'bg-red-900 bg-opacity-20'}`}>
                  <div className="font-bold">{iface.name}</div>
                  <div className="text-sm">Status: {iface.state}</div>
                  <div className="text-sm">{iface.ip || 'No IP'}</div>
                </div>
              ))}
            </div>
          </div>
          
          <div className="h-40">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data.network.history}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" tick={false} />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="download" 
                  stroke="#22c55e" 
                  strokeWidth={2} 
                  dot={false} 
                  name="Download MB/s" 
                />
                <Line 
                  type="monotone" 
                  dataKey="upload" 
                  stroke="#3b82f6" 
                  strokeWidth={2} 
                  dot={false} 
                  name="Upload MB/s" 
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
      
      {/* Process Table */}
      <div className={`p-4 rounded-lg ${theme === 'dark' ? 'bg-gray-800' : 'bg-gray-100'}`}>
        <div className="flex items-center justify-between mb-4">
          <IconLabel icon="⚙️" color="bg-blue-500">
            Process Monitor
          </IconLabel>
          <div>
            <span className="text-gray-500 mr-2">Total:</span> {data.processes.total} processes
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className={`border-b ${theme === 'dark' ? 'border-gray-700' : 'border-gray-300'}`}>
                <th className="text-left py-2 px-4">PID</th>
                <th className="text-left py-2 px-4">Name</th>
                <th className="text-left py-2 px-4">CPU %</th>
                <th className="text-left py-2 px-4">Memory %</th>
                <th className="text-left py-2 px-4">Status</th>
              </tr>
            </thead>
            <tbody>
              {data.processes.list.map((process, i) => (
                <tr 
                  key={i} 
                  className={`hover:${theme === 'dark' ? 'bg-gray-700' : 'bg-gray-200'}`}
                >
                  <td className="py-2 px-4">{process.pid}</td>
                  <td className="py-2 px-4 font-medium">{process.name}</td>
                  <td className="py-2 px-4">
                    <div className="flex items-center">
                      <span className="w-10">{process.cpu}%</span>
                      <div className="w-24 bg-gray-700 rounded-full h-2">
                        <div className="bg-blue-500 h-2 rounded-full" style={{ width: `${process.cpu * 3}%` }}></div>
                      </div>
                    </div>
                  </td>
                  <td className="py-2 px-4">
                    <div className="flex items-center">
                      <span className="w-10">{process.memory}%</span>
                      <div className="w-24 bg-gray-700 rounded-full h-2">
                        <div className="bg-green-500 h-2 rounded-full" style={{ width: `${process.memory * 3}%` }}></div>
                      </div>
                    </div>
                  </td>
                  <td className="py-2 px-4">
                    <span className="px-2 py-1 text-xs rounded-full bg-green-900 bg-opacity-20 text-green-500">Running</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      
      <footer className="mt-4 text-center text-gray-500 text-sm">
        Linux System Monitor v1.0.0 • Data refreshes every {refreshInterval} seconds • Press 'q' to quit
      </footer>
    </div>
  );
};

export default SystemMonitor;
