# Copyright (C) 2015 The PASTA Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

CFLAGS = -std=c11 -O2 -Wall -Wextra
CAKEFLAGS = dir_out=$(CURDIR) name=rxTools.dat

RXMODE_TARGETS = rxmode/native_firm/native_firm.elf rxmode/agb_firm/agb_firm.elf	\
	rxmode/twl_firm/twl_firm.elf

all: rxTools.dat

.PHONY: distclean
distclean: clean
	@rm -rf release/rxTools.dat release/ninjhax release/mset

.PHONY: clean
clean:
	@$(MAKE) -C rxtools clean
	@$(MAKE) -C rxmode/native_firm clean
	@$(MAKE) -C rxmode/agb_firm clean
	@$(MAKE) -C rxmode/twl_firm clean
	@$(MAKE) -C brahma clean
	@$(MAKE) -C theme clean
	@$(MAKE) -C rxinstaller clean
	@$(MAKE) $(CAKEFLAGS) -C CakeHax clean
	@rm -f payload.bin rxTools.dat

release: rxTools.dat rxtools/font.bin reboot/reboot.bin $(RXMODE_TARGETS)	\
	all-target-brahma all-target-theme rxinstaller.nds
	@mkdir -p release/mset release/ninjhax release/rxTools
	@cp rxTools.dat release
	@cp brahma/brahma.3dsx release/ninjhax/rxtools.3dsx
	@cp brahma/brahma.smdh release/ninjhax/rxtools.smdh
	@cp rxinstaller.nds release/mset/rxinstaller.nds

	@mkdir -p release/rxTools/system release/rxTools/theme

	@mkdir -p release/rxTools/theme/0
	@mv theme/*.bin release/rxTools/theme/0
	@cp theme/LANG.txt tools/themetool.sh tools/themetool.bat release/rxTools/theme/0

	@cp rxtools/font.bin release/rxTools/system
	@cp reboot/reboot.bin release/rxTools/system

	@mkdir -p release/rxTools/system/patches
	@cp rxmode/native_firm/native_firm.elf release/rxTools/system/patches
	@cp rxmode/agb_firm/agb_firm.elf release/rxTools/system/patches
	@cp rxmode/twl_firm/twl_firm.elf release/rxTools/system/patches

	@cp doc/QuickStartGuide.pdf doc/rxTools.pdf release/

rxTools.dat: rxtools/rxtools.bin
	@$(MAKE) $(CAKEFLAGS) -C CakeHax bigpayload
	@dd if=rxtools/rxtools.bin of=$@ seek=272 conv=notrunc

rxinstaller.nds:
	@$(MAKE) -C rxinstaller

all-target-brahma:
	$(MAKE) -C brahma

reboot/reboot.bin:
	$(MAKE) -C $(dir $@) $(notdir $@)

$(RXMODE_TARGETS):
	$(MAKE) -C $(dir $@) $(notdir $@)

rxtools/rxtools.bin:
	@$(MAKE) -C $(dir $@) all
	@dd if=$@ of=$@ bs=896K count=1 conv=sync,notrunc

.PHONY: all-target-theme
all-target-theme:
	@$(MAKE) -C theme

.PHONY: rxtools/font.bin
rxtools/font.bin:
	@$(MAKE) -C $(dir $@) $(notdir $@)
