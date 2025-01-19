// css.js
'use strict';

const css = `
/*
   Logging container:
   - position: relative so .logging-toast can overlay .logging-active
   - inline-block to place it next to h1
   - min-width ensures "LOGGING DISABLED" won't wrap
   - fixed height to keep a consistent vertical size
*/
.logging-container {
    position: relative;
    display: inline-block;
    margin-left: 20px;

    /* Ensure no wrapping of "LOGGING DISABLED" */
    min-width: 150px;

    /* Force a consistent height for the pill shape */
    height: 30px;
}

/*
   LOGGING ACTIVE label:
   - Pill shape (border-radius: 9999px)
   - 3px border (jamovi blue #3498db)
   - White background, orange text
   - EXACT height: 30px (matching .logging-container)
   - Display flex to center text
*/
.logging-active {
    display: flex;
    align-items: center;
    justify-content: center;

    width: 100%;              /* fill the container's width */
    height: 100%;             /* 30px from .logging-container */
    box-sizing: border-box;   /* so padding + border are included */

    font-size: 1em;
    font-weight: bold;
    text-transform: uppercase;
    white-space: nowrap;

    color: #3e6da9;
    #background-color: #fff;
    border: 3px solid #3e6da9;
    border-radius: 9999px;
    box-shadow: 0px 2px 5px rgba(0, 0, 0, 0.3);
    padding: 0 16px; /* horizontal padding inside the pill */
}

/* Show/hide utility classes */
.hidden {
    display: none !important;
}
.visible {
    display: flex !important; /* must match .logging-active's "display: flex" */
}

/*
   The toast that overlays the .logging-active label:
   - same pill shape, same dimension (width=100%, height=100%)
   - jamovi-blue text (#3498db)
   - absolute position => covers label
*/
.logging-toast {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    box-sizing: border-box;        /* consistent with label */

    display: flex;
    align-items: center;
    justify-content: center;
    white-space: nowrap;

    font-size: 1em;
    font-weight: bold;
    text-transform: uppercase;

    color: #fff;
    background-color: #3e6da9;
    border: 3px solid #3e6da9;
    border-radius: 9999px;
    box-shadow: none;
    padding: 0 16px;

    opacity: 0;                     /* for fade-in/out */
    transition: opacity 0.5s;
    z-index: 9999;
}

.logging-toast.show {
    opacity: 1;
}

/*
 File dialog styles
*/
.file-dialog-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
}

.file-dialog {
    background: white;
    border-radius: 8px;
    width: 400px;
    padding: 20px;
    box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.25);
    position: relative;
}

.file-dialog-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 10px;
    display: flex;
    align-items: center;
}

.file-dialog-title-icon {
    width: 40px;
    height: 40px;
    background-color: #2e6cb9;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 10px;
}

.file-dialog-title-text {
    font-size: 1.2em;
    color: #2e6cb9;
    margin: 0;
}

.file-dialog-list {
    border: 2px dashed #ccc;
    padding: 20px;
    margin-bottom: 10px;
    text-align: center;
    height: 100px;
    overflow-y: auto;
}

.file-dialog-button-container {
    display: flex;
    justify-content: space-between;
}

.file-item {
    margin: 5px 0;
    font-size: 14px;
    text-align: left;
}

/*
 Button styling
*/
.button-style {
    display: inline-block;
    padding: 3px 5px;
    font-size: 14px;
    text-align: center;
    text-decoration: none;
    outline: none;
    color: white;
    background-color: #3498db;
    background-image: linear-gradient(to bottom, #3498db, #2980b9);
    border: none;
    border-radius: 5px;
    box-shadow: 0 3px #969696;
    cursor: pointer;
}

.button-style:hover {
    background-color: #3cb0fd;
    background-image: linear-gradient(to bottom, #3cb0fd, #3498db);
}

.button-style:active {
    background-color: #3498db;
    background-image: linear-gradient(to bottom, #3498db, #2980b9);
    box-shadow: 0 3px #DADADA;
    transform: translateY(4px);
}

/* Specific customizations for each button */
#butsf-file span, #butsf-reshape span {
    text-decoration: underline;
}

/*
 Tooltip styling
*/
.custom-tooltip {
    display: none;
    position: absolute;
    background-color: white;
    color: black;
    padding: 4px 7px;
    border-radius: 14px;
    z-index: 1000;
    white-space: nowrap;
    box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.2);
    border: 2px solid #3498db;
}
`;

let node = document.createElement('style');
node.innerHTML = css;
document.body.appendChild(node);

module.exports = undefined;
