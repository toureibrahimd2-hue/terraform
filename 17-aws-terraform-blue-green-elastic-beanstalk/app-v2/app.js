const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Read from environment variables (set by Terraform)
const ENVIRONMENT = process.env.ENVIRONMENT || 'unknown';
const VERSION     = process.env.VERSION     || '0.0';
const STATUS      = process.env.STATUS      || 'staging';

// Middleware to log requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    version: VERSION,
    environment: ENVIRONMENT,
    deploymentStatus: STATUS,
    timestamp: new Date().toISOString()
  });
});

// Main route
app.get('/', (req, res) => {
  const isProduction = STATUS.toLowerCase() === 'production';
  const envEmoji     = ENVIRONMENT.toLowerCase() === 'green' ? '🟢' : '🔵';
  const badgeColor   = isProduction ? '#4CAF50' : '#FF9800';
  const bgGradient   = ENVIRONMENT.toLowerCase() === 'green'
    ? 'linear-gradient(135deg, #11998e 0%, #38ef7d 100%)'
    : 'linear-gradient(135deg, #1a73e8 0%, #74b9ff 100%)';
  const accentColor  = ENVIRONMENT.toLowerCase() === 'green' ? '#11998e' : '#1a73e8';
  const versionColor = ENVIRONMENT.toLowerCase() === 'green' ? '#38ef7d' : '#74b9ff';

  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Version ${VERSION} - ${ENVIRONMENT.toUpperCase()} Environment</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 0;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          background: ${bgGradient};
        }
        .container {
          text-align: center;
          background: white;
          padding: 60px 80px;
          border-radius: 20px;
          box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          max-width: 600px;
        }
        h1 { color: ${accentColor}; font-size: 2.5em; margin-bottom: 20px; }
        .version { color: ${versionColor}; font-size: 3em; font-weight: bold; margin: 20px 0; }
        .environment {
          background: ${accentColor};
          color: white;
          padding: 15px 30px;
          border-radius: 50px;
          display: inline-block;
          font-size: 1.2em;
          margin: 20px 0;
        }
        .info { color: #666; margin-top: 30px; line-height: 1.8; }
        .badge {
          display: inline-block;
          background: ${badgeColor};
          color: white;
          padding: 5px 15px;
          border-radius: 20px;
          font-size: 0.9em;
          margin: 10px 5px;
        }
        .features {
          text-align: left;
          margin: 20px auto;
          max-width: 400px;
          background: #f5f5f5;
          padding: 20px;
          border-radius: 10px;
        }
        .features h3 { color: ${accentColor}; margin-top: 0; }
        .features ul { margin: 10px 0; padding-left: 20px; }
        .features li { margin: 8px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 Welcome to the Blue-Green Deployment Demo</h1>
        <div class="version">Version ${VERSION}</div>
        <div class="environment">${envEmoji} ${ENVIRONMENT.toUpperCase()} ENVIRONMENT</div>
        <div class="info">
          <p><strong>Status:</strong> <span class="badge">${STATUS.toUpperCase()}</span></p>
          <p>This is the <strong>${STATUS}</strong> environment running Version ${VERSION}.</p>

          <div class="features">
            <h3>✨ What's New in v2.0:</h3>
            <ul>
              <li>🎨 Refreshed UI with modern design</li>
              <li>⚡ Improved performance</li>
              <li>🔒 Enhanced security features</li>
              <li>📊 Better analytics tracking</li>
              <li>🐛 Critical bug fixes</li>
            </ul>
          </div>

          <p><strong>Server Time:</strong> ${new Date().toISOString()}</p>
          <p><strong>Hostname:</strong> ${require('os').hostname()}</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    version: VERSION,
    environment: ENVIRONMENT,
    status: STATUS,
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname(),
    platform: process.platform,
    nodeVersion: process.version,
    features: [
      'Refreshed UI',
      'Improved performance',
      'Enhanced security',
      'Better analytics',
      'Bug fixes'
    ]
  });
});

// New feature endpoint (only in v2.0)
app.get('/api/features', (req, res) => {
  res.json({
    version: VERSION,
    newFeatures: [
      {
        name: 'Modern UI',
        description: 'Complete redesign with modern aesthetics',
        status: 'completed'
      },
      {
        name: 'Performance Boost',
        description: '50% faster load times',
        status: 'completed'
      },
      {
        name: 'Advanced Analytics',
        description: 'Real-time insights and reporting',
        status: 'completed'
      }
    ]
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Application v${VERSION} (${ENVIRONMENT} - ${STATUS}) is running on port ${PORT}`);
  console.log(`🌐 Server started at ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});