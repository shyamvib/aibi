import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 3001,
    strictPort: true,
    // Allow all hosts, including ngrok domains
    cors: true,
    hmr: {
      // This is the key setting for ngrok - use port 443 for https tunnels
      clientPort: 443,
      // Allow any host to connect
      host: '0.0.0.0'
    },
    // Explicitly allow all hosts
    allowedHosts: 'all'
  },
  preview: {
    port: 3001,
    strictPort: true,
    host: true
  }
});
