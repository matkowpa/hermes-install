# hermes-install

Workflow Cline (szablon w repo `hermes-install`). Instaluje aplikację "Hermes":
klonuje repozytorium, instaluje zależności i aplikuje konfigurację.

Aby podpowiadanie `/hermes-install` działało w innym projekcie, skopiuj ten plik do
`<projekt>\.clinerules\workflows\hermes-install.md`.

Kroki:

1. Zapytaj użytkownika o URL repozytorium Hermes (`$REPO_URL`), jeśli nie został podany.
   Opcjonalnie: ścieżka instalacji (`$INSTALL_PATH`, domyślnie `<projekt>\hermes`)
   oraz plik konfiguracyjny (`$CONFIG_PATH`).
2. Sprawdź, czy `git` jest dostępny (`git --version`); jeśli nie — przerwij i poproś
   o instalację gita.
3. Uruchom installer (ścieżka do tego repo — dostosuj, jeśli repo sklonowano gdzie indziej):

```
powershell -ExecutionPolicy Bypass -File "C:\Users\alusm\OneDrive\Dokumenty\Tata\projekty\hermes-install\install-hermes.ps1" -RepoUrl "$REPO_URL" -InstallPath "$INSTALL_PATH"
```

   Z plikiem konfiguracyjnym — dodaj `-ConfigPath "$CONFIG_PATH"`.

4. Sprawdź wynik: installer kończy się komunikatem `==> Done. Hermes installed at ...`.
   W razie błędu pokaż użytkownikowi pełny output i poproś o decyzję.
5. Po udanej instalacji wypisz: ścieżkę instalacji, użyte polecenie instalacji
   zależności oraz lokalizację pliku `hermes.config.json` do edycji.

> UWAGA: installer jest idempotentny — przy istniejącym repozytorium w
> `$INSTALL_PATH` robi `git pull` zamiast ponownego klonu.
