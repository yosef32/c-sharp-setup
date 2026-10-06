# C# ו-Visual Studio Code, שלב אחר שלב

השלבים האלה מתקינים את Git, את .NET SDK 10, את Visual Studio Code ואת ההרחבות של C#. אחר כך אפשר להריץ את הדוגמה, ליצור תוכנית חדשה, או להסיר את הכלים.

צריך חיבור לאינטרנט. אפשר להריץ את ההתקנה שוב. מה שכבר מותקן נשאר כמו שהוא.

C# Dev Kit חינמי ליחידים, לסטודנטים ולעבודה על קוד פתוח. בפתיחה הראשונה, Visual Studio Code עשוי לבקש להתחבר עם חשבון Microsoft.

## 1. התקנה ב-Windows

מתאים ל-Windows 10 מגרסה 1809 ומעלה, או ל-Windows 11. המחשב צריך להיות 64 סיביות.

### אפשרות א. לחיצה כפולה

1. פותחים את התיקייה שבה נמצאים הסקריפטים.
2. לוחצים פעמיים על `setup-windows.cmd`.
3. אם Windows מבקש אישור, בוחרים **Yes**. כך .NET SDK מותקן לכל המחשב.
4. מחכים עד שהחלון מודיע שהמחשב מוכן ל-C#.
5. לוחצים על מקש כלשהו כדי לסגור את החלון.

בסיום, Visual Studio Code פותח את התיקייה `HelloCSharp`.

### אפשרות ב. PowerShell

1. פותחים את התיקייה שבה נמצאים הסקריפטים.
2. לוחצים על שורת הכתובת, מקלידים `powershell` ולוחצים Enter.
3. מריצים:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

4. אם Windows מבקש אישור, בוחרים **Yes**.
5. מחכים עד שהחלון מודיע שהמחשב מוכן ל-C#.

### מה ההתקנה עושה

1. מתקינה את WinGet אם הפקודה `winget` חסרה.
2. מתקינה את Git.
3. מתקינה את .NET SDK 10. ה-SDK כולל גם את סביבת ההרצה.
4. מתקינה את Visual Studio Code.
5. מתקינה את .NET Install Tool, את הרחבת C# ואת C# Dev Kit.
6. יוצרת תוכנית לדוגמה בשם `HelloCSharp` בתיקייה הנוכחית.
7. מריצה את התוכנית פעם אחת.
8. פותחת את התיקייה ב-Visual Studio Code.

ממשיכים אל [הרצת הדוגמה](#3-הרצת-הדוגמה).

## 2. התקנה ב-Mac

### אפשרות א. לחיצה כפולה

1. פותחים את התיקייה שבה נמצאים הסקריפטים.
2. לוחצים פעמיים על `setup-mac.command`.
3. אם macOS מודיע שאי אפשר לפתוח את הקובץ, לוחצים עליו לחיצה ימנית, בוחרים **Open**, ואז שוב **Open**.
4. אם נפתח חלון להתקנת Xcode Command Line Tools, מסיימים את ההתקנה הזו ואז לוחצים שוב פעמיים על `setup-mac.command`.
5. אם Homebrew מבקש את סיסמת ה-Mac, מקלידים אותה ולוחצים Return. הסיסמה לא מופיעה על המסך בזמן ההקלדה.
6. מחכים עד ש-Terminal מודיע שה-Mac מוכן ל-C#.
7. לוחצים Return כדי לסגור את החלון.

בסיום, Visual Studio Code פותח את התיקייה `HelloCSharp`.

### אפשרות ב. Terminal

1. פותחים את Terminal.
2. עוברים לתיקייה שבה נמצאים הסקריפטים. לדוגמה:

```bash
cd ~/Downloads/c-sharp-setup
```

3. מריצים:

```bash
chmod +x setup-mac.sh
./setup-mac.sh
```

4. אם הופיע חלון של Xcode Command Line Tools, מסיימים אותו ואז מריצים שוב את `./setup-mac.sh`.
5. מקלידים את סיסמת ה-Mac אם Homebrew מבקש.

### מה ההתקנה עושה

1. בודקת אם Xcode Command Line Tools מותקנים, ופותחת את חלון ההתקנה אם הם חסרים.
2. מתקינה את Homebrew אם הוא חסר.
3. מתקינה את Git.
4. מתקינה את .NET SDK 10 דרך Homebrew. אם ההתקנה הזו לא מסתיימת, הסקריפט משתמש במתקין של Microsoft ומוסיף את `~/.dotnet` ל-PATH.
5. מתקינה את Visual Studio Code.
6. מתקינה את .NET Install Tool, את הרחבת C# ואת C# Dev Kit.
7. יוצרת תוכנית לדוגמה בשם `HelloCSharp` בתיקייה הנוכחית.
8. מריצה את התוכנית פעם אחת.
9. פותחת את התיקייה ב-Visual Studio Code.

## 3. הרצת הדוגמה

סקריפט ההתקנה משאיר את `HelloCSharp` פתוח ב-Visual Studio Code.

1. עובדים בחלון החדש של `HelloCSharp`. אם היה פתוח חלון ישן של Visual Studio Code, סוגרים אותו.
2. לוחצים **F5**.
3. או פותחים את **Run and Debug** ומפעילים את **Launch HelloCSharp**.

הפעולה בונה את הפרויקט ואז מריצה אותו במצב ניפוי שגיאות. התוכנית מדפיסה:

```text
Hello, World!
```

אפשר גם לפתוח את הטרמינל באותו חלון ולהריץ:

```bash
dotnet run
```

אם C# Dev Kit מבקש, מתחברים לחשבון. כך נפתחים תצוגת הפתרון, ניפוי השגיאות והבדיקות.

## 4. יצירת פרויקט חדש ב-Windows

קודם מריצים את [ההתקנה ב-Windows](#1-התקנה-ב-windows). הפרויקט החדש הוא תוכנית קונסול, והוא נוצר בתיקייה הנוכחית. בלחיצה כפולה זו התיקייה שבה נמצא הסקריפט.

השם צריך להתחיל באות, ולהכיל רק אותיות באנגלית, מספרים וקו תחתון, עד 50 תווים. `MyApp` הוא שם תקין. `123App` ו-`My App` לא תקינים.

### אפשרות א. לחיצה כפולה, ואז קביעת השם

1. לוחצים פעמיים על `new-project-windows.cmd`.
2. נפתח חלון כדי לקבוע את שם הפרויקט. השם `MyApp` כבר מלא.
3. משנים את השם, או משאירים את `MyApp`. בוחרים **OK**.
4. מחכים עד שהתוכנית מדפיסה `Hello, World!`.
5. Visual Studio Code פותח את התיקייה החדשה.
6. לוחצים על מקש כלשהו כדי לסגור את חלון ההתקנה.
7. ב-Visual Studio Code לוחצים **F5**, או מפעילים את **Launch** עם שם הפרויקט מתוך **Run and Debug**.

בוחרים **Cancel** כדי לעצור בלי ליצור פרויקט.

אם כבר יש תיקייה בשם הזה, הסקריפט מבקש שם אחר.

### אפשרות ב. העברת השם מ-PowerShell

1. פותחים PowerShell בתיקייה שבה רוצים ליצור את הפרויקט.
2. מריצים:

```powershell
powershell -ExecutionPolicy Bypass -File .\new-project-windows.ps1 -Name MyApp
```

3. מחליפים את `MyApp` בשם שרוצים.
4. בחלון Visual Studio Code שנפתח, לוחצים **F5**.

## 5. יצירת פרויקט חדש ב-Mac

קודם מריצים את [ההתקנה ב-Mac](#2-התקנה-ב-mac). כללי השם זהים לאלה של Windows.

### אפשרות א. לחיצה כפולה, ואז קביעת השם

1. לוחצים פעמיים על `new-project-mac.command`.
2. אם macOS חוסם את הקובץ, לוחצים עליו לחיצה ימנית, בוחרים **Open**, ואז שוב **Open**.
3. נפתח חלון כדי לקבוע את שם הפרויקט. השם `MyApp` כבר מלא.
4. משנים את השם, או משאירים את `MyApp`. בוחרים **Create**.
5. מחכים עד שהתוכנית מדפיסה `Hello, World!`.
6. Visual Studio Code פותח את התיקייה החדשה.
7. לוחצים Return כדי לסגור את חלון Terminal.
8. ב-Visual Studio Code לוחצים **F5**, או מפעילים את **Launch** עם שם הפרויקט מתוך **Run and Debug**.

בוחרים **Cancel** כדי לעצור בלי ליצור פרויקט.

### אפשרות ב. העברת השם מ-Terminal

1. פותחים את Terminal בתיקייה שבה רוצים ליצור את הפרויקט.
2. מריצים:

```bash
chmod +x new-project-mac.sh
./new-project-mac.sh MyApp
```

3. מחליפים את `MyApp` בשם שרוצים.
4. בחלון Visual Studio Code שנפתח, לוחצים **F5**.

אפשר גם להריץ את התוכנית מהטרמינל שבתוך Visual Studio Code:

```bash
dotnet run
```

## 6. הסרת הכלים ב-Windows

הפעולה מסירה את הרחבת C#, את .NET Install Tool, את C# Dev Kit, את Visual Studio Code, את .NET SDK 10 ואת Git. WinGet נשאר מותקן.

לחיצה כפולה תמיד מבקשת להקליד `YES`, והיא לא מוחקת את התיקייה `HelloCSharp`. האפשרויות הנוספות למטה מיועדות ל-PowerShell.

### אפשרות א. לחיצה כפולה

1. לוחצים פעמיים על `uninstall-windows.cmd`.
2. קוראים מה עומד להימחק.
3. מקלידים `YES` ולוחצים Enter.
4. מחכים עד שהחלון מודיע שההתקנה של C# הוסרה.
5. לוחצים על מקש כלשהו כדי לסגור את החלון.
6. פותחים טרמינל חדש כדי שה-PATH יתעדכן. מפעילים מחדש את Windows אם מסיר ההתקנה ביקש זאת.

כל טקסט שאינו `YES` מבטל את ההסרה.

### אפשרות ב. PowerShell, עם אישור

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1
```

מקלידים `YES` כשהסקריפט שואל.

### אפשרות ג. בלי שאלת אישור

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force
```

`-Force` לא מבקש להקליד `YES`.

### אפשרות ד. למחוק גם את תוכנית הדוגמה

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -RemoveSample
```

`-RemoveSample` מוחק תיקיית `HelloCSharp` בתיקייה הנוכחית, אם זו תוכנית הדוגמה. הסקריפט עדיין מבקש להקליד `YES`.

### אפשרות ה. בלי שאלת אישור, וגם מחיקת הדוגמה

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force -RemoveSample
```

## 7. הסרת הכלים ב-Mac

הפעולה מסירה את הרחבות C#, את Visual Studio Code, את .NET SDK ואת עותק Git של Homebrew. Homebrew ו-Xcode Command Line Tools נשארים מותקנים.

לחיצה כפולה תמיד מבקשת להקליד `YES`, והיא לא מוחקת את התיקייה `HelloCSharp`. האפשרויות הנוספות למטה מיועדות ל-Terminal.

### אפשרות א. לחיצה כפולה

1. לוחצים פעמיים על `uninstall-mac.command`.
2. אם macOS חוסם את הקובץ, לוחצים עליו לחיצה ימנית, בוחרים **Open**, ואז שוב **Open**.
3. מקלידים `YES` ולוחצים Return.
4. מקלידים את סיסמת ה-Mac אם מסיר ההתקנה מבקש.
5. מחכים עד ש-Terminal מודיע שההתקנה של C# הוסרה.
6. לוחצים Return כדי לסגור את החלון.
7. פותחים טרמינל חדש כדי שה-PATH יתעדכן.

### אפשרות ב. Terminal, עם אישור

```bash
chmod +x uninstall-mac.sh
./uninstall-mac.sh
```

מקלידים `YES` כשהסקריפט שואל.

### אפשרות ג. בלי שאלת אישור

```bash
./uninstall-mac.sh --yes
```

`--yes` לא מבקש להקליד `YES`.

### אפשרות ד. למחוק גם את תוכנית הדוגמה

```bash
./uninstall-mac.sh --remove-sample
```

`--remove-sample` מוחק תיקיית `HelloCSharp` בתיקייה הנוכחית, אם זו תוכנית הדוגמה. הסקריפט עדיין מבקש להקליד `YES`.

### אפשרות ה. בלי שאלת אישור, וגם מחיקת הדוגמה

```bash
./uninstall-mac.sh --yes --remove-sample
```

אפשר לכתוב את שתי האפשרויות בכל סדר.

## כל האפשרויות

| המטרה | איך |
| --- | --- |
| התקנה ב-Windows | לחיצה כפולה על `setup-windows.cmd` |
| התקנה ב-Windows מ-PowerShell | `powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1` |
| התקנה ב-Mac | לחיצה כפולה על `setup-mac.command` |
| התקנה ב-Mac מ-Terminal | `./setup-mac.sh` |
| הרצת הדוגמה | **F5**, או **Launch HelloCSharp** |
| הרצת הדוגמה מהטרמינל | `dotnet run` |
| פרויקט חדש ב-Windows | לחיצה כפולה על `new-project-windows.cmd` וקביעת השם |
| פרויקט חדש ב-Windows עם שם | `powershell -ExecutionPolicy Bypass -File .\new-project-windows.ps1 -Name MyApp` |
| פרויקט חדש ב-Mac | לחיצה כפולה על `new-project-mac.command` וקביעת השם |
| פרויקט חדש ב-Mac עם שם | `./new-project-mac.sh MyApp` |
| הסרת הכלים ב-Windows | לחיצה כפולה על `uninstall-windows.cmd`, ואז `YES` |
| הסרת הכלים ב-Windows בלי שאלה | `powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force` |
| הסרת הכלים והדוגמה ב-Windows | `powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -RemoveSample` |
| הסרת הכלים והדוגמה ב-Windows בלי שאלה | `powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force -RemoveSample` |
| הסרת הכלים ב-Mac | לחיצה כפולה על `uninstall-mac.command`, ואז `YES` |
| הסרת הכלים ב-Mac בלי שאלה | `./uninstall-mac.sh --yes` |
| הסרת הכלים והדוגמה ב-Mac | `./uninstall-mac.sh --remove-sample` |
| הסרת הכלים והדוגמה ב-Mac בלי שאלה | `./uninstall-mac.sh --yes --remove-sample` |
