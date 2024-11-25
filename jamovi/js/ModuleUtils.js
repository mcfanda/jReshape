'use strict';

/**
 * Tooltip Management Utility
 */
const TooltipManager = {
    createTooltip(element, text, position = 'center') {
        const tooltip = document.createElement('div');
        tooltip.className = 'custom-tooltip';
        tooltip.textContent = text;
        document.body.appendChild(tooltip);

        element.addEventListener('mouseover', (event) => {
            tooltip.style.display = 'block';

            // Dynamic positioning
            const tooltipWidth = tooltip.offsetWidth;
            const tooltipHeight = tooltip.offsetHeight;
            const { pageX, pageY } = event;

            switch (position) {
                case 'left':
                    tooltip.style.left = `${pageX - tooltipWidth - 10}px`;
                    break;
                case 'right':
                    tooltip.style.left = `${pageX + 10}px`;
                    break;
                case 'center':
                default:
                    tooltip.style.left = `${pageX - tooltipWidth / 2}px`;
            }
            tooltip.style.top = `${pageY + 10}px`;
        });

        element.addEventListener('mousemove', (event) => {
            const tooltipWidth = tooltip.offsetWidth;
            const { pageX } = event;

            if (position === 'center') {
                tooltip.style.left = `${pageX - tooltipWidth / 2}px`;
            }
        });

        element.addEventListener('mouseout', () => {
            tooltip.style.display = 'none';
        });
    }
};

/**
 * Keyboard Shortcut Management Utility
 */
const KeyboardShortcuts = {
    addShortcut(keys, callback) {
        document.addEventListener('keydown', (event) => {
            const keyCombo = keys.map((key) => key.toLowerCase());
            const isMatch = keyCombo.every((key) => {
                if (key === 'ctrl') return event.ctrlKey;
                if (key === 'shift') return event.shiftKey;
                if (key === 'alt') return event.altKey;
                return event.key.toLowerCase() === key;
            });

            if (isMatch) {
                event.preventDefault();
                callback(event);
            }
        }, false);
    }
};

/**
 * DOM Manipulation Utility
 */
const DOMUtils = {
    insertAfter(referenceNode, newNode) {
        referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
    },

    createDivWithClass(className) {
        const div = document.createElement('div');
        div.className = className;
        return div;
    },

    addClass(element, className) {
        element.classList.add(className);
    },

    removeClass(element, className) {
        element.classList.remove(className);
    }
};

// We export all utilities
module.exports = {
    TooltipManager,
    KeyboardShortcuts,
    DOMUtils
};
