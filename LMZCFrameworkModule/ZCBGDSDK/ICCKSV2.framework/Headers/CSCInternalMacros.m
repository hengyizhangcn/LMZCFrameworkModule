/*
 * This file is part of the CSCWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CSCInternalMacros.h"

void sd_executeCleanupBlock (__strong sd_cleanupBlock_t *block) {
    (*block)();
}
