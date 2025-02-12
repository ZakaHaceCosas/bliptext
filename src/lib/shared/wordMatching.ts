export const WORD_MATCH_REGEX = /\*\*[^*]+\*\*|\*[^*]+\*|\[[^\]\*]+\]\([^\)]+\)|[^\s]+[.,_]?/g;

// warning - this function is not secure and should not be used for moderation
export function isValidWord(newWord: string): boolean {
    if (newWord.length > 100) return false;

    if (/[\uD800-\uDBFF][\uDC00-\uDFFF]/.test(newWord)) {
        return false;
    }

    const isBold = /^\*\*[\p{L}\p{N}](?:[\p{L}\p{N}_-]*[\p{L}\p{N}])?\*\*$/u.test(newWord);
    const isItalic = /^\*[\p{L}\p{N}](?:[\p{L}\p{N}_-]*[\p{L}\p{N}])?\*$/u.test(newWord);
    const isPlainWord = /^[\p{L}\p{N}](?:[\p{L}\p{N}_-]*[\p{L}\p{N}])?[.,]?$/u.test(newWord);
    const isLink = /^\[[\p{L}\p{N}](?:[\p{L}\p{N}_-]*[\p{L}\p{N}])?\]\((https?:\/\/[^\s)]{1,100})\)$/u.test(newWord);

    return isBold || isItalic || isPlainWord || isLink;
}