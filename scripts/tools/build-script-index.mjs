// Compatibility entry point for existing Cloudflare Pages build settings.
// The static index discovers scripts in the browser; no generation is needed.
import { access } from 'node:fs/promises';

await access(new URL('../index.html', import.meta.url));
console.log('Script index ready. The script list updates automatically from GitHub.');
