# Autoupdate

Status: **umgesetzt** (`Launcher/`-Projekt + `.github/workflows/release.yml`). Dieses Dokument
beschreibt, wie das System funktioniert und wie man eine neue Version released.

## Warum kein Velopack

Velopack ist eine .NET-Bibliothek, `desktop-bud` ist reines GDScript (`config/features` in
`project.godot` listet nur `"4.7", "GL Compatibility"`, kein Mono/C#). Godot hat keinen eingebauten
Auto-Updater (siehe die offenen Godot-Proposals
[#8451](https://github.com/godotengine/godot-proposals/issues/8451),
[#8588](https://github.com/godotengine/godot-proposals/issues/8588),
[#2089](https://github.com/godotengine/godot-proposals/issues/2089)), aber es gibt ein etabliertes,
rein Godot-natives Muster dafür, das hier umgesetzt wurde: ein kleines, stabiles **Launcher**-Executable
lädt das eigentliche Spiel als `.pck`-Datei zur Laufzeit nach
(`ProjectSettings.load_resource_pack()` kann laut offizieller Doku komplett neue Szenen/Skripte
einbringen, die im Basis-Executable gar nicht vorhanden waren). Damit gibt es das klassische
"Programm kann sich nicht selbst überschreiben"-Problem gar nicht erst – nur die `.pck`-Datei wird
ausgetauscht, nie die laufende `.exe`.

## Architektur

Zwei getrennte Godot-Projekte in diesem Repo:

- **Repo-Root (`project.godot`, `Scenes/`, …)** – das eigentliche Spiel, unverändert. Wird nur noch als
  **`.pck`** exportiert (`export_presets.cfg`, Preset "Windows Desktop", `--export-pack`), nie mehr als
  eigene `.exe` für die Auslieferung.
- **`Launcher/`** – eigenes, minimales Godot-Projekt, das tatsächlich als `.exe` an Nutzer ausgeliefert
  wird (`Launcher/export_presets.cfg`, `--export-release`). Eigene `project.godot` mit denselben
  `[display]`-Fenstereinstellungen wie das Hauptspiel (transparent, `always_on_top`, `no_focus`,
  borderless) – das ist nötig, weil diese Einstellungen beim Engine-Start aus dem Executable-eigenen
  `project.godot` gelesen werden und ein nachträglich geladenes `.pck` sie nicht überschreiben kann.
  - `Launcher/launcher.gd` (Hauptszene `Launcher/Scenes/launcher.tscn`): lädt beim Start
    `user://desktop-bud.pck` falls vorhanden (schon mal aktualisiert), sonst die Kopie, die direkt neben
    der `.exe` mitgeliefert wird (`OS.get_executable_path().get_base_dir()`) – der allererste Start
    funktioniert also immer offline. Danach `get_tree().change_scene_to_file("res://Scenes/global.tscn")`
    – ab hier läuft das Spiel exakt wie bisher.
  - `Launcher/update_checker.gd` (Autoload `UpdateChecker`, läuft unabhängig von der Szene weiter):
    prüft per `HTTPRequest` gegen `https://api.github.com/repos/Felilou/Desktop-Bud/releases/latest`,
    vergleicht `tag_name` gegen `user://installed_version.txt`. Bei neuer Version wird das
    `.pck`-Release-Asset nach `user://desktop-bud.pck.new` heruntergeladen und **erst nach
    vollständigem Download** zu `user://desktop-bud.pck` umbenannt (kein halbfertiges Pack im
    Ernstfall). Wirkt beim **nächsten** Programmstart – kein Hot-Swap der laufenden Szene, keine
    Sprechblasen-Benachrichtigung (bewusst, siehe unten). Schlägt der Request fehl (offline, kein
    Release, Rate-Limit) → stiller No-Op, der zuletzt gecachte/mitgelieferte Stand bleibt aktiv.

## Bewusste Einschränkungen

- **Kein Code-Signing.** Der Windows-Build ist unsigniert, SmartScreen zeigt beim Download/Start eine
  Warnung. Üblich für frühe Indie-/Hobby-Projekte, zurückgestellt bis es relevant wird.
- **Keine Signatur-/Checksum-Prüfung** des heruntergeladenen `.pck`. Vertretbar ohne sensible Daten.
- **Kein Fortschrittsbalken** für den Download – die Pack-Dateien hier sind klein.
- **Kein Hot-Reload**: ein gefundenes Update wird erst beim nächsten Start aktiv, nicht sofort.

## Release-Ablauf für eine neue Version

1. `config/version` in `project.godot` (Root) hochzählen.
2. Tag `vX.Y.Z` pushen (Schema passend zum bereits existierenden `v0.1.0`).
3. `.github/workflows/release.yml` läuft automatisch: lädt Godot 4.7.1 headless + Export-Templates,
   exportiert `build/desktop-bud.pck` (Root-Projekt) und `build/Launcher.exe` (`Launcher/`-Projekt),
   packt beides in ein Zip, erstellt ein GitHub Release für den Tag und lädt **beide** Assets hoch:
   das Zip (für Neuinstallationen) und das nackte `desktop-bud.pck` separat (das lädt
   `update_checker.gd` bei künftigen Versionen nach, ohne den Launcher jedes Mal neu herunterzuladen).

Damit reicht ab jetzt "Version hochzählen, Tag pushen" – kein manueller Build-/Upload-Schritt mehr
nötig.
