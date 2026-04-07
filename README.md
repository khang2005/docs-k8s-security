# K8s Audit Security Dashboard

Documentation site built with MkDocs and hosted on Cloudflare R2 + Workers.

## Project Structure

```
mkdoc/
├── docs/                    # MkDocs source
│   ├── index.md            # Home page
│   ├── architecture/       # Architecture docs
│   ├── installation/       # Installation guides
│   ├── reference/          # Reference docs
│   └── assets/            # Static assets
├── worker/                 # Cloudflare Worker
│   ├── src/index.ts       # Worker source
│   ├── wrangler.toml      # Worker config
│   └── package.json
├── ci/                     # CI/CD pipeline
│   └── Jenkinsfile
├── src/                    # Dagger module
│   └── main.go
├── mkdocs.yml             # MkDocs config
└── pyproject.toml         # Python deps
```

## Local Development

### Build Documentation

```bash
pip install mkdocs-material mkdocs-mermaid2-plugin
mkdocs serve
```

### Deploy Worker

```bash
cd worker
npm install
wrangler deploy
```

## CI/CD Pipeline

The documentation is automatically deployed via Jenkins when changes are pushed to the main branch.

1. Build docs with MkDocs
2. Upload to R2 bucket
3. Deploy Cloudflare Worker

## License

MIT
