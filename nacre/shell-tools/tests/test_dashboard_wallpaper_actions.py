"""Real hero buttons call the current wallpaper interface and open picker/colors."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from test_overview_ui import prepare_overview

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT.parent / "shell"


class DashboardWallpaperActionsTests(unittest.TestCase):
    def test_current_manual_next_contract_and_picker_buttons(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            prepare_overview(target)
            fixtures = target / "fixtures"
            definitions = {
                "NacreWallpapers": 'property string poster:"";property string displayPreview:"";property string displayPath:"";property bool displayDynamic:false;property bool displayAnimated:false;property bool rotationReady:true;property var preferences:({palettePersonality:"natural"});property int nextCalls:0;function advanceRotation(manual){if(manual)nextCalls++;}',
                "WallpaperPlayback": "property bool batteryPaused:false;property bool paused:false;property bool sleeping:false;property bool locked:false",
                "NacreDashboardState": "property var home:({})",
                "NacreColorsApp": "property int opens:0;function open(){opens++;}",
                "NacrePanelState": 'property string mode:"";function openMode(value){mode=value;}',
            }
            for name, body in definitions.items():
                (fixtures / (name + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject {" + body + "}"
                )
                with (fixtures / "qmldir").open("a") as manifest:
                    manifest.write(f"\nsingleton {name} 1.0 {name}.qml\n")
            (fixtures / "ActionButton.qml").write_text(
                (SHELL / "widgets/ActionButton.qml")
                .read_text()
                .replace("import qs.services", 'import "."')
            )
            (fixtures / "NacreScrollBar.qml").write_text(
                (SHELL / "widgets/NacreScrollBar.qml").read_text()
            )
            with (fixtures / "qmldir").open("a") as manifest:
                manifest.write(
                    "\nActionButton 1.0 ActionButton.qml\nNacreScrollBar 1.0 NacreScrollBar.qml\n"
                )
            for name in ("NacreTodayPage", "NacreDashboardHero"):
                source = (
                    (SHELL / "modules/dashboard" / (name + ".qml"))
                    .read_text()
                    .replace("import qs.widgets", 'import "fixtures"')
                    .replace("import qs.services", "")
                )
                (target / (name + ".qml")).write_text(source)
            (target / "NacreDashboardSummary.qml").write_text(
                "import QtQuick\nItem {property bool active:false;implicitHeight:300}"
            )
            (target / "tst_hero.qml").write_text("""import QtQuick
import QtTest
import "fixtures"
TestCase {
 name:"DashboardWallpaperActions";width:1000;height:650;visible:true;when:windowShown
 Component {id:page;NacreTodayPage {width:940;height:562;shouldUpdate:true;visibilities:({})}}
 function test_manual_next_and_controls(){
  const view=createTemporaryObject(page,this);wait(40);
  const next=findChild(view,"dashboardNextWallpaper"),colors=findChild(view,"dashboardColors"),picker=findChild(view,"dashboardWallpapers");
  mouseClick(next,15,15);compare(NacreWallpapers.nextCalls,1);
  NacreWallpapers.rotationReady=false;mouseClick(next,15,15);compare(NacreWallpapers.nextCalls,1);
  mouseClick(colors,15,15);compare(NacreColorsApp.opens,1);
  mouseClick(picker,15,15);compare(NacrePanelState.mode,"wallpaper");
  verify(picker.width>next.width);verify(picker.y+picker.height<next.parent.y);
 }
}
""")
            result = subprocess.run(
                [str(runner), "-input", str(target), "-o", "-,txt"],
                capture_output=True,
                text=True,
                timeout=20,
                env={**os.environ, "QT_QPA_PLATFORM": "offscreen"},
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)
