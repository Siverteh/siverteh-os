"""Native summary layout keeps calendar, gauges and real-spectrum baselines aligned."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from test_overview_ui import prepare_overview

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT.parent / "shell"


class DashboardSummaryTests(unittest.TestCase):
    def test_actual_cards_alignment_narrow_layout_and_spectrum_states(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            prepare_overview(target)
            fixtures = target / "fixtures"
            definitions = {
                "Updates": "property int count:8",
                "NacreMediaDetails": "property var spectrum:[]",
                "Environment": 'function env(name){return "fixture-user";}function execDetached(args){}',
            }
            for name, body in definitions.items():
                (fixtures / (name + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject {" + body + "}"
                )
                with (fixtures / "qmldir").open("a") as manifest:
                    manifest.write(f"\nsingleton {name} 1.0 {name}.qml\n")
            for name in (
                "NacreDashboardSummary",
                "NacreCompactMetric",
                "NacreAudioSpectrum",
            ):
                source = (
                    (SHELL / "modules/dashboard" / (name + ".qml"))
                    .read_text()
                    .replace("import qs.widgets", 'import "fixtures"')
                    .replace("import qs.services", "")
                    .replace("import Quickshell", "")
                    .replace("Quickshell.", "Environment.")
                )
                (target / (name + ".qml")).write_text(source)
            (target / "tst_summary.qml").write_text("""import QtQuick
import QtTest
import "fixtures"
TestCase {
 name:"DashboardSummary";width:1100;height:1200;visible:true;when:windowShown
 Component {id:summary;NacreDashboardSummary {width:940;height:376;active:true}}
 Component {id:meter;NacreAudioSpectrum {width:272;height:72;active:true;playing:true}}
 function init(){DesktopSettings.data={animations:false};NacreMediaDetails.spectrum=[];NacrePlayers.active=null;}
 function test_bottom_alignment_and_compact_controls_fit(){
  const scene=createTemporaryObject(summary,this);wait(40);
  const calendar=findChild(scene,"dashboardCalendar"),host=findChild(scene,"dashboardHost"),metrics=findChild(scene,"dashboardMetrics"),media=findChild(scene,"dashboardMedia"),spectrum=findChild(scene,"dashboardSpectrum");
  compare(calendar.y+calendar.height,metrics.y+metrics.height);compare(calendar.y+calendar.height,spectrum.y+spectrum.height);
  verify(host.y+host.height<metrics.y);verify(media.y+media.height<spectrum.y);
  verify(host.x>=calendar.x+calendar.width);verify(media.x>=host.x+host.width);
  compare(findChild(host,"hostLine4").text,"8 updates");
  const play=findChild(media,"mediaToggle");const point=play.mapToItem(media,0,0);verify(point.y+play.height<=media.height);
  scene.width=580;scene.height=scene.implicitHeight;wait(30);
  verify(host.y>=calendar.y+calendar.height);verify(metrics.y>=host.y+host.height);
  verify(media.y>=metrics.y+metrics.height);compare(spectrum.y+spectrum.height,scene.height);
 }
 function test_spectrum_samples_and_inactive_motion_are_honest(){
  DesktopSettings.data={animations:true};
  const bars=createTemporaryObject(meter,this);wait(30);
  const values=Array(32).fill(.5);values[0]=1;bars.samples=values;
  tryCompare(findChild(bars,"spectrumBar0"),"height",72);
  tryCompare(findChild(bars,"spectrumBar1"),"height",37);
  const first=findChild(bars,"spectrumBar0"),second=findChild(bars,"spectrumBar1");
  compare(first.y+first.height,second.y+second.height);
  bars.playing=false;tryCompare(first,"height",2);
  bars.playing=true;DesktopSettings.data={animations:true,reduceMotion:true};tryCompare(first,"height",2);
  DesktopSettings.data={animations:true};tryCompare(first,"height",72);
  bars.active=false;tryCompare(first,"height",2);
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
