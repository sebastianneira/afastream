# Environment Setup

Common config is stored in the bsconfig.json and launch.json but each developer also has their own local setup. We store this in an env file. This file is not stored in the git repo so you need to add it at the root of the project as `.env`. Inside you'll want to put the following:

```
LAUNCH_HOST=<IP-TO-YOUR-ROKU>
LAUNCH_PASSWORD=<PASS-FOR-ROKU>
```

If you want you can add multiple Roku devices by using comments to enable or disable lines with `#` at the beginning of the line.
