"""Exercise config updates in temporary directories without installing software."""
import shlex
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SOURCE = (REPO / 'scripts/nvim.sh').read_text()
FUNCTIONS = SOURCE[SOURCE.index('backup_path() {'):SOURCE.index('\nchoice=$(choose')]
# Keep test filesystem operations away from the real user's home and XDG paths.
FUNCTIONS = FUNCTIONS.replace('$HOME', '$task_home').replace('${XDG_CONFIG_HOME:', '${task_config_home:')
FUNCTIONS = FUNCTIONS.replace('${ZDOTDIR:', '${task_zdotdir:').replace('${SHELL:-', '${task_shell:-')


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='simplyhost-installer-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / 'user'
        self.checkout = self.root / 'checkout'
        (self.checkout / 'scripts').mkdir(parents=True)
        shutil.copytree(REPO / 'config/nvim', self.checkout / 'config/nvim')
        self.config = self.home / '.config/nvim'

    def run_installer(self, command='install_lazyvim', mock='', piped=False):
        program = ('set -euo pipefail\ntask_home=' + shlex.quote(str(self.home)) + '\n'
                   + FUNCTIONS + '\n' + mock + '\n' + command + '\n')
        if piped:
            return subprocess.run(['bash'], input=program, text=True, capture_output=True)
        runner = self.checkout / 'scripts/test.sh'
        runner.write_text(program)
        return subprocess.run(['bash', str(runner)], text=True, capture_output=True)

    def install(self):
        result = self.run_installer()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_fresh_and_repeat_install(self):
        self.install()
        self.assertEqual((self.config / 'init.lua').read_bytes(), (REPO / 'config/nvim/init.lua').read_bytes())
        self.install()
        self.assertFalse(list(self.home.rglob('*.bak*')))

    def test_existing_lazyvim_preserves_custom_files_data_and_lock(self):
        self.install()
        custom = self.config / 'lua/config/keymaps.lua'
        custom.write_text('-- my shortcuts\n')
        lock = self.config / 'lazy-lock.json'
        lock.write_text('{"custom":true}')
        marker = self.home / '.local/share/nvim/preserved'
        marker.parent.mkdir(parents=True)
        marker.touch()
        theme = self.config / 'lua/plugins/colorscheme.lua'
        theme.write_text('-- old theme\n')
        (self.config / 'lua/plugins/colorscheme.lua.bak').write_text('-- older theme\n')
        (self.config / 'lua/plugins/dashboard.lua').unlink()
        self.install()
        self.assertEqual(custom.read_text(), '-- my shortcuts\n')
        self.assertEqual(lock.read_text(), '{"custom":true}')
        self.assertTrue(marker.exists())
        self.assertEqual((self.config / 'lua/plugins/colorscheme.lua.bak.1').read_text(), '-- old theme\n')
        self.assertEqual((self.config / 'lua/plugins/colorscheme.lua.bak').read_text(), '-- older theme\n')
        self.assertTrue((self.config / 'lua/plugins/dashboard.lua').exists())

    def test_non_lazyvim_config_is_backed_up(self):
        self.config.mkdir(parents=True)
        (self.config / 'init.vim').write_text('set number\n')
        self.install()
        self.assertEqual((self.home / '.config/nvim.bak/init.vim').read_text(), 'set number\n')
        self.assertTrue((self.config / 'init.lua').exists())

    def test_remote_download_and_failure(self):
        archive = self.root / 'source.tar.gz'
        with tarfile.open(archive, 'w:gz') as tar:
            tar.add(REPO / 'config/nvim', arcname='simplyhost-main/config/nvim')
        mock = 'curl() { cp ' + shlex.quote(str(archive)) + ' "$4"; }'
        result = self.run_installer(mock=mock, piped=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        theme = self.config / 'lua/plugins/colorscheme.lua'
        before = theme.read_bytes()
        result = self.run_installer(mock='curl() { return 1; }', piped=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(theme.read_bytes(), before)
        self.assertFalse(list(self.home.rglob('*.bak*')))

    def test_missing_managed_file_does_not_replace_existing_config(self):
        self.install()
        (self.checkout / 'config/nvim/lua/plugins/dashboard.lua').unlink()
        result = self.run_installer()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue((self.config / 'lua/plugins/dashboard.lua').exists())
        self.assertFalse(list(self.home.rglob('*.bak*')))

    def test_existing_neovim_skips_install(self):
        result = self.run_installer('ensure_neovim linux', mock='''
nvim() { :; }
install_neovim_archive() { return 99; }
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Neovim already installed', result.stdout)

    def test_custom_config_location(self):
        location = self.root / 'custom-config'
        result = self.run_installer('task_config_home=' + shlex.quote(str(location)) + '\ninstall_lazyvim')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((location / 'nvim/init.lua').exists())
        self.assertFalse(self.config.exists())

    def test_bash_path_persists_and_is_not_duplicated(self):
        self.home.mkdir()
        (self.home / '.bash_profile').write_text('# existing login setup\n')
        executable = self.home / '.local/bin/nvim'
        executable.parent.mkdir(parents=True)
        executable.write_text('#!/bin/sh\nexit 0\n')
        executable.chmod(0o755)
        result = self.run_installer('''
persist_neovim_path "$task_home/.local/bin" bash
persist_neovim_path "$task_home/.local/bin" bash
bash -c 'PATH=/usr/bin:/bin; source "$1"; command -v nvim' _ "$task_home/.bashrc"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(str(executable), result.stdout)
        for name in ['.bashrc', '.profile', '.bash_profile']:
            text = (self.home / name).read_text()
            self.assertEqual(text.count('export PATH='), 1)
        self.assertIn('# existing login setup', (self.home / '.bash_profile').read_text())

    def test_zsh_path_with_spaces_and_custom_zdotdir(self):
        directory = self.home / 'tools with spaces/bin'
        result = self.run_installer('''
task_zdotdir="$task_home/zsh-config"
persist_neovim_path "$task_home/tools with spaces/bin" zsh
bash -c 'PATH=/usr/bin:/bin; source "$1"; printf "%s" "$PATH"' _ "$task_zdotdir/.zshrc"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(str(directory) + ':/usr/bin:/bin', result.stdout)
        self.assertTrue((self.home / 'zsh-config/.zprofile').exists())

    def test_detected_install_repairs_startup_path(self):
        executable = self.home / '.local/bin/nvim'
        executable.parent.mkdir(parents=True)
        executable.write_text('#!/bin/sh\nexit 0\n')
        executable.chmod(0o755)
        result = self.run_installer('ensure_neovim linux', mock='''
command() {
  if [[ "$1" == -v && "$2" == nvim ]]; then return 1; fi
  builtin command "$@"
}
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Found existing Neovim', result.stdout)
        self.assertTrue((self.home / '.bashrc').exists())


if __name__ == '__main__':
    unittest.main()
