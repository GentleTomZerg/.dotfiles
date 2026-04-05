// Compatibility Prefix
const {
    Clipboard,
    Front,
    Hints,
    Normal,
    RUNTIME,
    Visual,
    aceVimMap,
    addSearchAlias,
    cmap,
    getClickableElements,
    imap,
    imapkey,
    iunmap,
    map,
    mapkey,
    readText,
    removeSearchAlias,
    tabOpenLink,
    unmap,
    unmapAllExcept,
    vmapkey,
    vunmap,
} = api;

// Map J and K to switch between tabs
api.unmap("K");
api.map("K", "E");
api.unmap("J");
api.map("J", "R");
// Map H and L to move forward or backwards within a tab
api.unmap("H");
api.map("H", "S");
api.unmap("L");
api.map("L", "D");
