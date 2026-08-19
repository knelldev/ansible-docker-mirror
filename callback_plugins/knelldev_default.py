# GNU General Public License v3.0+ (see LICENSES/GPL-3.0-or-later.txt or https://www.gnu.org/licenses/gpl-3.0.txt)
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026, knelldev

from ansible.plugins.callback.default import (  # pyright: ignore[reportMissingImports]
    CallbackModule as _Default,
)

DOCUMENTATION = """
    name: knelldev_default
    type: stdout
    short_description: Repository default stdout callback with task source names
    version_added: "1.0.0"
    description:
        - Uses Ansible's default stdout output under the repository callback
           identifier and prefixes task and handler banners with their source
           filename when Ansible provides one.
    extends_documentation_fragment:
        - default_callback
        - result_format_callback
    requirements:
        - set as stdout callback in ansible.cfg
"""


class CallbackModule(_Default):
    """Repository-named default stdout callback with source-name banners."""

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = "stdout"
    CALLBACK_NAME = "knelldev_default"
    CALLBACK_NEEDS_ENABLED = False

    @staticmethod
    def _display_name(task) -> str:
        """Return the normal task name prefixed by its source filename."""
        path = task.get_path()
        if not path:
            return task.get_name().strip()

        return (
            f"({path.rsplit(':', 1)[0].rsplit('/', 1)[-1]}) {task.get_name().strip()}"
        )

    def _task_start(self, task, prefix=None):
        super()._task_start(task, prefix=prefix)
        self._last_task_name = self._display_name(task)
