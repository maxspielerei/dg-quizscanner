#!/bin/bash
set -e
echo "=== Erstelle DG Scanner ==="

mkdir -p app/src/main/assets
mkdir -p app/src/main/java/com/dg/scanner
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p gradle/wrapper

cat > build.gradle << 'EOF'
buildscript {
    repositories { google(); mavenCentral() }
    dependencies { classpath 'com.android.tools.build:gradle:7.4.2' }
}
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
task clean(type: Delete) { delete rootProject.buildDir }
EOF

cat > settings.gradle << 'EOF'
rootProject.name = "DGScanner"
include ':app'
EOF

cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
android.suppressUnsupportedCompileSdk=34
EOF

cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

cat > gradlew << 'EOF'
#!/usr/bin/env sh
APP_HOME="$(cd "$(dirname "$0")"; pwd)"
exec java -classpath "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain "$@"
EOF
chmod +x gradlew

cat > app/build.gradle << 'EOF'
plugins { id 'com.android.application' }
android {
    compileSdk 34
    defaultConfig {
        applicationId "com.dg.scanner"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes { release { minifyEnabled false } }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.github.markusfisch:BarcodeScannerView:1.6.5'
    constraints {
        implementation('org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22') { because 'fix duplicates' }
        implementation('org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.22') { because 'fix duplicates' }
    }
}
EOF

cat > app/proguard-rules.pro << 'EOF'
-keep class de.markusfisch.android.barcodescannerview.** { *; }
EOF

cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.dg.scanner">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher"
        android:supportsRtl="true"
        android:theme="@style/Theme.DGScanner">

        <activity android:name=".MainActivity" android:exported="true"
            android:screenOrientation="fullSensor">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity android:name=".WebViewActivity" android:exported="false"
            android:screenOrientation="fullSensor" />

    </application>
</manifest>
EOF

# HTML direkt als Asset einbetten - kein Dateizugriff nötig
cat > app/src/main/assets/dg-quiz.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DG Quiz</title>
    <style>
        @keyframes bgShift {
            0%   { background-color: #0a3d3d; }
            50%  { background-color: #0d6060; }
            100% { background-color: #0a3d3d; }
        }
        body {
            font-family: sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background-color: #0a3d3d;
            animation: bgShift 3s ease-in-out infinite;
        }
        .card {
            text-align: center;
            background: white;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            width: 85%;
            max-width: 450px;
        }
        button {
            padding: 20px 40px;
            font-size: 1.3rem;
            font-weight: bold;
            cursor: pointer;
            background-color: #e67e22;
            color: white;
            border: none;
            border-radius: 12px;
            width: 100%;
        }
        button:active {
            transform: scale(0.98);
            background-color: #d35400;
        }
        .hidden { display: none; }
        .fade-in { animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        h2 { color: #2c3e50; line-height: 1.5; }
        .back-link {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            color: rgba(255,255,255,0.5);
            background-color: rgba(255,255,255,0.1);
            padding: 8px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.85rem;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .back-link:hover {
            color: rgba(255,255,255,0.8);
            background-color: rgba(255,255,255,0.15);
        }
        .pw-label {
            display: block;
            color: #2c3e50;
            font-size: 0.95rem;
            margin-bottom: 12px;
        }
        #pw-input {
            width: 100%;
            padding: 14px 16px;
            font-size: 1.1rem;
            border: 2px solid #ccc;
            border-radius: 10px;
            box-sizing: border-box;
            margin-bottom: 14px;
            outline: none;
            transition: border-color 0.2s;
            text-align: center;
            color: #2c3e50;
        }
        #pw-input:focus { border-color: #e67e22; }
        #pw-error {
            display: none;
            color: #c0392b;
            font-weight: bold;
            font-size: 1rem;
            background: #fde8e8;
            border: 2px solid #e74c3c;
            border-radius: 8px;
            padding: 12px 14px;
            margin-bottom: 14px;
        }
        #start-screen h2 {
            font-size: 1rem;
            text-align: center;
            line-height: 1.8;
        }
        .start-title {
            font-size: 1.5rem;
            font-weight: bold;
            color: #e67e22;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>

    <a href="#" id="back-link" class="back-link hidden" onclick="previousQuestion(); return false;">&#8592; zur&uuml;ck</a>

    <div class="card">

        <!-- PASSWORT -->
        <div id="password-screen">
            <h2 style="margin-top:0; text-align:center;">&#128274;</h2>
            <label class="pw-label">Gib das Passwort <strong>in Kleinbuchstaben</strong> ein.</label>
            <input type="text" id="pw-input" placeholder="Passwort"
                autocomplete="off" autocorrect="off" autocapitalize="none" spellcheck="false" />
            <div id="pw-error">Das war falsch!<br>Sucht in euren Kitteln nach Hinweisen.</div>
            <button onclick="checkPassword()">Weiter</button>
        </div>

        <!-- START -->
        <div id="start-screen" class="hidden">
            <div class="start-title">Super gemacht!</div>
            <h2>
                Nun braucht ihr noch 2 Sachen:<br><br>
                <strong>DEN R&Ouml;HREN-APPARAT</strong><br>
                Der ist im gr&uuml;nen Schrank. Habt ihr ihn schon ge&ouml;ffnet?<br><br>
                Au&szlig;erdem ben&ouml;tigt ihr die <strong>KUGELN</strong> in der roten Box.<br>
                &Ouml;ffnet den Kabelbinder mit einer Zange!<br>
                Und wo ist die Zange?<br>
                Untersucht nochmal genau den silbernen Koffer&nbsp;&hellip;<br><br>
                OK&nbsp;&hellip; bereit?<br><br>
                Los geht&rsquo;s mit den Fragen:
            </h2>
            <br>
            <button onclick="showQuestion()">Erste Frage</button>
        </div>

        <!-- FRAGEN -->
        <div id="question-screen" class="hidden">
            <h2 id="frage"></h2>
            <br>
            <button id="next-btn" onclick="nextQuestion()">N&auml;chste Frage</button>
        </div>

        <!-- ENDE -->
        <div id="end-screen" class="hidden">
            <h1 style="color:#27ae60; font-size:3rem; margin:0;">&#127881;</h1>
            <h2 style="color:#27ae60;">Geschafft!</h2>
        </div>

    </div>

    <script>
        var validPasswords = [
            'aquano','aquanoo','aquanooo','aquanoooo','aquanooooo',
            'aquanoooooo','aquanooooooo','aquanoooooooo','aquanooooooooo','aquanoooooooooo'
        ];

        function checkPassword() {
            var val = document.getElementById('pw-input').value.trim();
            var err = document.getElementById('pw-error');
            if (validPasswords.indexOf(val) !== -1) {
                err.style.display = 'none';
                document.getElementById('password-screen').style.display = 'none';
                document.getElementById('start-screen').style.display = 'block';
            } else {
                err.style.display = 'block';
            }
        }

        document.getElementById('pw-input').addEventListener('keydown', function(e) {
            if (e.key === 'Enter') checkPassword();
        });

        var fragen = [
            "Wenn <em>AquaMegaWorld</em> ein Erlebnisbad f&uuml;r alle Berliner ist, d&uuml;rfen daf&uuml;r ein paar Wohnh&auml;user gesprengt werden?",
            "Die Politiker haben den Bau von <em>AquaMegaWorld</em> beschlossen. Was meinst Du: h&auml;tten alle Berliner &uuml;ber den Bau von <em>AquaMegaWorld</em> abstimmen sollen?",
            "Sollten gefl&uuml;chtete, behinderte, erkrankte und arme Menschen <em>AquaMegaWorld</em> kostenlos besuchen d&uuml;rfen, wenn der Eintritt f&uuml;r alle Anderen dadurch teurer wird?",
            "Darf der Eintritt in <em>AquaMegaWorld</em> f&uuml;r Kinder h&ouml;her als 10&nbsp;&euro; sein?",
            "Menschen mit viel Geld bekommen in <em>AquaMegaWorld</em> einen eigenen Bereich gebaut, andere Menschen d&uuml;rfen da nicht rein. Ist das ok?",
            "Das Finale von &bdquo;The Voice of Germany&ldquo; wird in ganz Deutschland gezeigt und soll in <em>AquaMegaWorld</em> stattfinden.<br>Daf&uuml;r ist <em>AquaMegaWorld</em> f&uuml;r alle Berliner 2 Tage lang gesperrt.<br>Findest du das in Ordnung?",
            "Sollten alle Berliner zuhause Wasser sparen, wenn das Wasser im Sommer knapp wird, damit <em>AquaMegaWorld</em> weiter offen bleiben kann?",
            "Darf der Gesch&auml;ftsf&uuml;hrer von <em>AquaMegaWorld</em> alleine die Bauplanung &auml;ndern?",
            "Alle Berliner bezahlen die <em>AquaMegaWorld</em>-Firma f&uuml;r den aufwendigen Bau, der nun immer teurer wird. Ist das ok f&uuml;r dich?",
            "Darf die <em>AquaMegaWorld</em>-Firma das Mitbringen von Essen verbieten, weil sie eigene Snacks verkaufen will?",
            "Eigentlich war eine Bahn-Station neben <em>AquaMegaWorld</em> geplant. Weil das zu teuer wird, soll laut Baufirma ein eigener Bus f&uuml;r 50 Cent dorthin fahren. Ok f&uuml;r dich?",
            "Sollen alle Berliner f&uuml;r den Bau von <em>AquaMegaWorld</em> zus&auml;tzlich Steuern zahlen?",
            "Wenn <em>AquaMegaWorld</em> Pleite geht: soll Berlin (und alle Berliner) dann die Schulden zahlen?",
            "In <em>AquaMegaWorld</em> wird dein Handyempfang nicht funktionieren.<br>Du kannst nur in das WLAN von dort. (1&nbsp;&euro; pro Stunde)<br>Ok f&uuml;r dich?",
            "Wenn <em>AquaMegaWorld</em> schon fast voll ist und nur noch wenige Menschen rein d&uuml;rfen:<br>sollten dann Menschen, die in Berlin wohnen, bevorzugt werden?"
        ];

        var aktuelleFrageIndex = 0;

        function showQuestion() {
            document.getElementById('start-screen').style.display = 'none';
            document.getElementById('question-screen').style.display = 'block';
            document.getElementById('back-link').classList.remove('hidden');
            aktuelleFrageIndex = 0;
            updateQuestion();
        }

        function updateQuestion() {
            document.getElementById('frage').innerHTML = fragen[aktuelleFrageIndex];
            document.getElementById('next-btn').textContent =
                aktuelleFrageIndex === fragen.length - 1 ? 'Abschlie\\u00dfen' : 'N\\u00e4chste Frage';
        }

        function nextQuestion() {
            var qScreen = document.getElementById('question-screen');
            if (aktuelleFrageIndex === fragen.length - 1) {
                qScreen.style.display = 'none';
                document.getElementById('back-link').classList.add('hidden');
                document.getElementById('end-screen').style.display = 'block';
                return;
            }
            qScreen.classList.remove('fade-in');
            void qScreen.offsetWidth;
            qScreen.classList.add('fade-in');
            aktuelleFrageIndex++;
            updateQuestion();
        }

        function previousQuestion() {
            var qScreen = document.getElementById('question-screen');
            if (aktuelleFrageIndex === 0) {
                qScreen.style.display = 'none';
                document.getElementById('back-link').classList.add('hidden');
                document.getElementById('start-screen').style.display = 'block';
            } else {
                qScreen.classList.remove('fade-in');
                void qScreen.offsetWidth;
                qScreen.classList.add('fade-in');
                aktuelleFrageIndex--;
                updateQuestion();
            }
        }
    </script>

</body>
</html>

HTMLEOF

cat > app/src/main/java/com/dg/scanner/MainActivity.java << 'EOF'
package com.dg.scanner;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;
import de.markusfisch.android.barcodescannerview.widget.BarcodeScannerView;

public class MainActivity extends Activity {
    // Diese URL im QR-Code wird abgefangen
    private static final String TRIGGER_URL = "https://spielehrei.org/q-intro/";
    private static final int REQUEST_CAMERA = 1;
    private BarcodeScannerView scannerView;
    private volatile boolean launched = false;

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_CAMERA) {
            if (grantResults.length > 0 && grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Kamera-Berechtigung erforderlich!", Toast.LENGTH_LONG).show();
                finish();
            } else {
                scannerView.openAsync();
            }
        }
    }

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        scannerView = findViewById(R.id.scanner);
        scannerView.setCropRatio(.75f);
        scannerView.setOnBarcodeListener(result -> {
            if (!launched) {
                launched = true;
                final String scanned = result.getText().trim();
                // Trigger-URL -> Asset laden; alles andere normal öffnen
                final boolean isAsset = scanned.equals(TRIGGER_URL);
                runOnUiThread(() -> {
                    Intent intent = new Intent(MainActivity.this, WebViewActivity.class);
                    intent.putExtra(WebViewActivity.EXTRA_IS_ASSET, isAsset);
                    intent.putExtra(WebViewActivity.EXTRA_URL, scanned);
                    startActivity(intent);
                });
            }
            return false;
        });
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{Manifest.permission.CAMERA}, REQUEST_CAMERA);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        launched = false;
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            scannerView.openAsync();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        scannerView.close();
    }
}
EOF

cat > app/src/main/java/com/dg/scanner/WebViewActivity.java << 'EOF'
package com.dg.scanner;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class WebViewActivity extends Activity {
    public static final String EXTRA_URL = "url";
    public static final String EXTRA_IS_ASSET = "is_asset";
    private WebView webView;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().getDecorView().setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        setContentView(R.layout.activity_webview);
        webView = findViewById(R.id.web_view);
        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        webView.setWebViewClient(new WebViewClient());

        boolean isAsset = getIntent().getBooleanExtra(EXTRA_IS_ASSET, false);
        String url = getIntent().getStringExtra(EXTRA_URL);

        if (isAsset) {
            // Direkt aus APK laden - keine Permission nötig!
            webView.loadUrl("file:///android_asset/dg-quiz.html");
        } else if (url != null && !url.isEmpty()) {
            webView.loadUrl(url);
        } else {
            finish();
        }
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) webView.goBack();
        else super.onBackPressed();
    }
}
EOF

cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:background="#000000">
    <de.markusfisch.android.barcodescannerview.widget.BarcodeScannerView
        android:id="@+id/scanner"
        android:layout_width="match_parent" android:layout_height="match_parent" />
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal" android:layout_marginBottom="40dp"
        android:text="QR-Code in den Rahmen halten" android:textColor="#ffffff"
        android:textSize="16sp" android:background="#88000000" android:padding="12dp" />
</FrameLayout>
EOF

cat > app/src/main/res/layout/activity_webview.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent">
    <WebView android:id="@+id/web_view"
        android:layout_width="match_parent" android:layout_height="match_parent" />
</FrameLayout>
EOF

cat > app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources><string name="app_name">DG Scanner</string></resources>
EOF

cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.DGScanner" parent="Theme.AppCompat.Light.NoActionBar" />
</resources>
EOF

cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources><color name="ic_launcher_background">#0a3d3d</color></resources>
EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#e67e22"
        android:pathData="M3,3h7v7H3V3zM4.5,4.5v4h4v-4H4.5zM14,3h7v7h-7V3zM15.5,4.5v4h4v-4H15.5zM3,14h7v7H3V14zM4.5,15.5v4h4v-4H4.5zM14,14h2v2h-2v-2zM18,14h3v3h-3v-3zM16,18h2v3h-2v-3zM19,18h2v2h-2v-2zM6,6h2v2H6V6zM17,6h2v2h-2V6zM6,17h2v2H6V17z"/>
</vector>
EOF

LAUNCHER_XML='<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>'
echo "$LAUNCHER_XML" > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
echo "$LAUNCHER_XML" > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml

echo "=== Fertig: DG Scanner ==="
