#!/bin/bash
#This script is used to patch QEMU within pve-qemu-kvm9, supporting versions 9 and 10 (not supporting KVM7 and KVM8; higher versions have not been tested). Simply place this script in the qemu directory and run it once before making the package. After running, you can use git tools to generate patch files for your specific QEMU version.
#This script is based on the open-source project https://github.com/zhaodice/proxmox-ve-anti-detection, handling repetitive tasks.
#Authors: Li Xiaoliu & DadaShuai666 Produced on August 24, 2024 https://space.bilibili.com/565938745

SED=${SED:=sed}

BRAND="DELL" # 4 letters only!
BRAND_CRC16="0x1030"

$SED -Ei "s/(QEMU|KVM) Virtual/${BRAND}/g" **/*.c

$SED -i 's/QEMU v" QEMU_VERSION/'${BRAND}' v" QEMU_VERSION/g' block/vhdx.c
$SED -i 's/QEMU VVFAT", 10/'${BRAND}' VVFAT", 10/g' block/vvfat.c
$SED -i 's/QEMU Microsoft Mouse/'${BRAND}' Microsoft Mouse/g' chardev/msmouse.c
$SED -i 's/QEMU Wacom Pen Tablet/'${BRAND}' Wacom Pen Tablet/g' chardev/wctablet.c
$SED -i 's/QEMU vhost-user-gpu/'${BRAND}' vhost-user-gpu/g' contrib/vhost-user-gpu/vhost-user-gpu.c
$SED -i 's/desc->oem_id/ACPI_BUILD_APPNAME6/g' hw/acpi/aml-build.c
$SED -i 's/desc->oem_table_id/ACPI_BUILD_APPNAME8/g' hw/acpi/aml-build.c
$SED -i 's/array, ACPI_BUILD_APPNAME8/array, "PTL "/g' hw/acpi/aml-build.c
$SED -i 's/"QEMU/"Intel/g' hw/acpi/aml-build.c

grep "do this once" hw/acpi/vmgenid.c >/dev/null
if [ $? -eq 0 ]; then
	echo "hw/acpi/vmgenid.c is already patched! skipping"
else
	$SED -i 's/    Aml \*ssdt/       \/\/FUCK YOU~~~\n       return;\/\/do this once\n    Aml \*ssdt/g' hw/acpi/vmgenid.c
fi
$SED -i 's/"QEMUQEQEMUQEMU/"ASUSASASUSASUS/g' hw/acpi/core.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/acpi/core.c
if [ -f hw/arm/nseries.c ]; then
    $SED -i 's/QEMU N800/'${BRAND}' N800/g' hw/arm/nseries.c
    $SED -i 's/QEMU LCD panel/'${BRAND}' LCD panel/g' hw/arm/nseries.c
    $SED -i 's/strcpy((void *) w, "QEMU ")/strcpy((void *) w, "'${BRAND}' ")/g' hw/arm/nseries.c
    $SED -i 's/"1.1.10-qemu" : "1.1.6-qemu"/"1.1.10-asus" : "1.1.6-asus"/g' hw/arm/nseries.c
fi
$SED -i "s/QEMU 'SBSA Reference' ARM Virtual Machine/"${BRAND}" 'SBSA Reference' ARM Real Machine/g" hw/arm/sbsa-ref.c
$SED -i 's/QEMU Sun Mouse/'${BRAND}' Sun Mouse/g' hw/char/escc.c
$SED -i 's/info->vendor = "RHT"/info->vendor = "DEL"/g' hw/display/edid-generate.c
$SED -i 's/QEMU Monitor/'${BRAND}' Monitor/g' hw/display/edid-generate.c
$SED -i 's/uint16_t model_nr = 0x1234;/uint16_t model_nr = 0xA05F;/g' hw/display/edid-generate.c

grep "do this once" hw/i386/acpi-build.c >/dev/null
if [ $? -eq 0 ]; then
	echo "hw/i386/acpi-build.c is already patched! skipping"
else
	$SED -i '/static void build_dbg_aml(Aml \*table)/,/ /s/{/{\n     return;\/\/do this once/g' hw/i386/acpi-build.c
	$SED -i '/create fw_cfg node/,/}/s/}/}*\//g' hw/i386/acpi-build.c
	$SED -i '/create fw_cfg node/,/}/s/{/\/*{/g' hw/i386/acpi-build.c
fi
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/i386/fw_cfg.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/i386/pc_piix.c
$SED -i 's/Standard PC (i440FX + PIIX, 1996)/'${BRAND}' M4A88TD-Mi440fx/g' hw/i386/pc_piix.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/i386/pc_q35.c
$SED -i 's/Standard PC (Q35 + ICH9, 2009)/'${BRAND}' M4A88TD-Mq35/g' hw/i386/pc_q35.c
$SED -i 's/mc->name, pcmc->smbios_legacy_mode,/"'${BRAND}'-PC", pcmc->smbios_legacy_mode,/g' hw/i386/pc_q35.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/ide/atapi.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/ide/core.c

#$SED -i 's/QM%05d/'${BRAND}'-lixiaoliu666-%02d/g' hw/ide/core.c  # IDE/SATA hard drive serial number (drive_serial_str, 20 characters) is for creating a fixed hard drive serial number. The following three lines are for creating a random hard drive serial number.
$SED -i 's/#include "trace.h"/#include "trace.h"\n#include <stdio.h>/g' hw/ide/core.c  # Add the necessary header files to the line below that uses the random function rand().
$SED -i 's/if (dev->serial)/srand(time(NULL));\n\tif (dev->serial)/g' hw/ide/core.c  # Add `srand(time(NULL));` to the line below that uses the random function `rand()` to seed the pseudo-random number generation algorithm. Without this, randomization will not be possible.
$SED -i 's/QM%05d", s->drive_serial/'${BRAND}'-%04d-lixiaoliu", rand()%10000/g' hw/ide/core.c  # IDE SATA hard drive serial number drive_serial_str (20 characters)
$SED -i 's/qemu_hw_version()/s->drive_serial_str/g' hw/ide/core.c  # IDE/SATA firmware version Random firmware, using the first 8 digits of the hard drive serial number (8-character size)
$SED -i 's/0x09, 0x03, 0x00, 0x64, 0x64, 0x01, 0x00/0x09, 0x03, 0x00, 0x64, 0x64, 0x9a, 0x02/g' hw/ide/core.c  # IDE/SATA power-on time (power on hours) has been changed to 666 hours (0x029a).
$SED -i 's/0x0c, 0x03, 0x00, 0x64, 0x64, 0x00, 0x00/0x0c, 0x03, 0x00, 0x64, 0x64, 0x9a, 0x02/g' hw/ide/core.c  # IDE/SATA power cycle count has been changed to 666 times (0x029a).

$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/adb-kbd.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/adb-mouse.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/ads7846.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/hid.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/ps2.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/tsc2005.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/input/tsc210x.c
$SED -i 's/"QEMU Virtio/"'${BRAND}'/g' hw/input/virtio-input-hid.c
$SED -i 's/QEMU M68K Virtual Machine/'${BRAND}' M68K Real Machine/g' hw/m68k/virt.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/misc/pvpanic-isa.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/nvme/ctrl.c
$SED -i 's/0x51454d5520434647ULL/0x4155535520434647ULL/g' hw/nvram/fw_cfg.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/nvram/fw_cfg-acpi.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/pci-host/gpex.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/ppc/prep.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/ppc/e500plat.c
$SED -i 's/qemu-e500/asus-e500/g' hw/ppc/e500plat.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/riscv/virt.c
$SED -i 's/s16s8s16s16s16/s11s4s51s41s91/g' hw/scsi/mptconfig.c
$SED -i 's/QEMU MPT Fusion/'${BRAND}' MPT Fusion/g' hw/scsi/mptconfig.c
$SED -i 's/"QEMU"/"'${BRAND}'"/g' hw/scsi/mptconfig.c
$SED -i 's/0000111122223333/1145141919810000/g' hw/scsi/mptconfig.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/scsi/scsi-bus.c
$SED -i 's/qemu_hw_version()/"666"/g' hw/scsi/scsi-bus.c # SCSI bus version - 4 chars
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/scsi/megasas.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/scsi/scsi-disk.c
$SED -i 's/qemu_hw_version()/"666"/g' hw/scsi/scsi-disk.c # SCSI firmware version - 5 chars
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/scsi/spapr_vscsi.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/sd/sd.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/ufs/lu.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-audio.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-hid.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-hub.c
$SED -i 's/314159/114514/g' hw/usb/dev-hub.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-mtp.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-network.c
$SED -i 's/"RNDIS\/QEMU/"RNDIS\/'${BRAND}'/g' hw/usb/dev-network.c
$SED -i 's/400102030405/400114514405/g' hw/usb/dev-network.c
$SED -i 's/s->vendorid = 0x1234/s->vendorid = 0x8086/g' hw/usb/dev-network.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-serial.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-smartcard-reader.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-storage.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-uas.c
$SED -i 's/27842/33121/g' hw/usb/dev-uas.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/dev-wacom.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/u2f-emulated.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/u2f-passthru.c
$SED -i 's/"QEMU/"'${BRAND}'/g' hw/usb/u2f.c
$SED -i 's/"BOCHS/"INTEL/g' include/hw/acpi/aml-build.h
$SED -i 's/"BXPC/"PC8086/g' include/hw/acpi/aml-build.h
$SED -i 's/"QEMU0002/"'${BRAND}'0002/g' include/standard-headers/linux/qemu_fw_cfg.h
$SED -i 's/0x51454d5520434647ULL/0x4155535520434647ULL/g' include/standard-headers/linux/qemu_fw_cfg.h
$SED -i 's/"QEMU/"'${BRAND}'/g' migration/migration.c
$SED -i 's/"QEMU/"'${BRAND}'/g' migration/rdma.c
$SED -i 's/0x51454d5520434647ULL/0x4155535520434647ULL/g' pc-bios/optionrom/optionrom.h
$SED -i 's/"QEMU/"'${BRAND}'/g' pc-bios/s390-ccw/virtio-scsi.h
$SED -i 's/"QEMU/"'${BRAND}'/g' roms/seabios/src/fw/ssdt-misc.dsl
$SED -i 's/"QEMU/"'${BRAND}'/g' roms/seabios-hppa/src/fw/ssdt-misc.dsl
$SED -i 's/KVMKVMKVM\\0\\0\\0/\\1\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0/g' target/i386/kvm/kvm.c
$SED -i 's/QEMUQEMUQEMUQEMU/ASUSASUSASUSASUS/g' target/s390x/tcg/misc_helper.c
$SED -i 's/"QEMU/"'${BRAND}'/g' target/s390x/tcg/misc_helper.c
$SED -i 's/"KVM/"ATX/g' target/s390x/tcg/misc_helper.c
$SED -i 's/t->bios_characteristics_extension_bytes\[1\] = 0x14;/t->bios_characteristics_extension_bytes\[1\] = 0x0F;/g' hw/smbios/smbios.c
$SED -i 's/t->voltage = 0;/t->voltage = 0x8B;/g' hw/smbios/smbios.c
$SED -i 's/t->external_clock = cpu_to_le16(0);/t->external_clock = cpu_to_le16(100);/g' hw/smbios/smbios.c
$SED -i 's/t->l1_cache_handle = cpu_to_le16(0xFFFF);/t->l1_cache_handle = cpu_to_le16(0x0039);/g' hw/smbios/smbios.c
$SED -i 's/t->l2_cache_handle = cpu_to_le16(0xFFFF);/t->l2_cache_handle = cpu_to_le16(0x003A);/g' hw/smbios/smbios.c
$SED -i 's/t->l3_cache_handle = cpu_to_le16(0xFFFF);/t->l3_cache_handle = cpu_to_le16(0x003B);/g' hw/smbios/smbios.c
$SED -i 's/t->processor_family = 0x01;/t->processor_family = 0xC6;/g' hw/smbios/smbios.c
$SED -i 's/t->processor_characteristics = cpu_to_le16(0x02);/t->processor_characteristics = cpu_to_le16(0x04);/g' hw/smbios/smbios.c
$SED -i 's/t->memory_type = 0x07;/t->memory_type = 0x18;/g' hw/smbios/smbios.c
$SED -i 's/t->total_width = cpu_to_le16(0xFFFF);/t->total_width = cpu_to_le16(64);/g' hw/smbios/smbios.c
$SED -i 's/t->data_width = cpu_to_le16(0xFFFF);/t->data_width = cpu_to_le16(64);/g' hw/smbios/smbios.c
$SED -i 's/t->minimum_voltage = cpu_to_le16(0);/t->minimum_voltage = cpu_to_le16(1350);/g' hw/smbios/smbios.c
$SED -i 's/t->maximum_voltage = cpu_to_le16(0);/t->maximum_voltage = cpu_to_le16(1500);/g' hw/smbios/smbios.c
$SED -i 's/t->configured_voltage = cpu_to_le16(0);/t->configured_voltage = cpu_to_le16(1350);/g' hw/smbios/smbios.c
$SED -i 's/t->location = 0x01;/t->location = 0x03;/g' hw/smbios/smbios.c
$SED -i 's/t->error_correction = 0x06;/t->error_correction = 0x03;/g' hw/smbios/smbios.c
$SED -i 's/"QEMU TCG CPU version/"TCG CPU version/g' target/i386/cpu.c
$SED -i 's/"Microsoft Hv/"GenuineIntel/g' target/i386/cpu.c  # Solving the Nvidia VGPU driver issue #43

# Add the default SPD information for 8GB DDR3L memory; serial number 0000000 is not processed.
$SED -i 's/for (i = 0; i < nb_eeprom/eeprom_buf[0]=0x92;\neeprom_buf[1]=0x10;\neeprom_buf[2]=0x0B;\neeprom_buf[3]=0x03;\neeprom_buf[4]=0x06;\neeprom_buf[5]=0x21;\neeprom_buf[6]=0x02;\neeprom_buf[7]=0x09;\neeprom_buf[8]=0x03;\neeprom_buf[9]=0x52;\neeprom_buf[0x0a]=0x01;\neeprom_buf[0x0b]=0x08;\neeprom_buf[0x0c]=0x0A;\neeprom_buf[0x0d]=0x00;\neeprom_buf[0x0e]=0xFE;\neeprom_buf[0x0f]=0x00;\neeprom_buf[0x10]=0x5A;\neeprom_buf[0x11]=0x78;\neeprom_buf[0x12]=0x5A;\neeprom_buf[0x13]=0x30;\neeprom_buf[0x14]=0x5A;\neeprom_buf[0x15]=0x11;\neeprom_buf[0x16]=0x0E;\neeprom_buf[0x17]=0x81;\neeprom_buf[0x18]=0x20;\neeprom_buf[0x19]=0x08;\neeprom_buf[0x1a]=0x3C;\neeprom_buf[0x1b]=0x3C;\neeprom_buf[0x1c]=0x00;\neeprom_buf[0x1d]=0xF0;\neeprom_buf[0x1e]=0x83;\neeprom_buf[0x1f]=0x81;\neeprom_buf[0x3c]=0x0F;\neeprom_buf[0x3d]=0x11;\neeprom_buf[0x3e]=0x65;\neeprom_buf[0x3f]=0x00;\neeprom_buf[0x70]=0x00;\neeprom_buf[0x71]=0x00;\neeprom_buf[0x72]=0x00;\neeprom_buf[0x73]=0x00;\neeprom_buf[0x74]=0x00;\neeprom_buf[0x75]=0x01;\neeprom_buf[0x76]=0x98;\neeprom_buf[0x77]=0x07;\neeprom_buf[0x78]=0x25;\neeprom_buf[0x79]=0x18;\neeprom_buf[0x7a]=0x00;\neeprom_buf[0x7b]=0x00;\neeprom_buf[0x7c]=0x00;\neeprom_buf[0x7d]=0x00;\neeprom_buf[0x7e]=0x3D;\neeprom_buf[0x7f]=0xA7;\neeprom_buf[0x80]=0x4B;\neeprom_buf[0x81]=0x48;\neeprom_buf[0x82]=0x58;\neeprom_buf[0x83]=0x31;\neeprom_buf[0x84]=0x36;\neeprom_buf[0x85]=0x30;\neeprom_buf[0x86]=0x30;\neeprom_buf[0x87]=0x43;\neeprom_buf[0x88]=0x39;\neeprom_buf[0x89]=0x53;\neeprom_buf[0x8a]=0x33;\neeprom_buf[0x8b]=0x4C;\neeprom_buf[0x8c]=0x2F;\neeprom_buf[0x8d]=0x33;\neeprom_buf[0x8e]=0x32;\neeprom_buf[0x8f]=0x47;\neeprom_buf[0x90]=0x20;\neeprom_buf[0x91]=0x20;\neeprom_buf[0x92]=0x00;\neeprom_buf[0x93]=0x00;\neeprom_buf[0x94]=0x00;\neeprom_buf[0x95]=0x00;\neeprom_buf[0xfe]=0x00;\neeprom_buf[0xff]=0x5A;\nfor (i = 0; i < nb_eeprom/g' hw/i2c/smbus_eeprom.c

# 0x1afe is the ID of the QEMU virtual machine. For compatibility reasons, only SUBVENDOR_ID is processed here. Processing VENDOR_ID=0x1af4 or VENDOR_ID=0x1b36 with other values will cause some devices to become unusable.
#$SED -i 's/#define PCI_SUBVENDOR_ID_REDHAT_QUMRANET 0x1af4/#define PCI_SUBVENDOR_ID_REDHAT_QUMRANET 0x8086/g' include/hw/pci/pci.h

# If VENDOR_ID=0x1af4 or VENDOR_ID=0x1b36 is set to other values, some devices will become unusable. For example, SCSI, virtioNET, and virtioBlock will not be recognized.
#$SED -i 's/#define PCI_VENDOR_ID_REDHAT_QUMRANET    0x1af4/#define PCI_VENDOR_ID_REDHAT_QUMRANET    0x8085/g' include/hw/pci/pci.h
#$SED -i 's/#define PCI_VENDOR_ID_REDHAT             0x1b36/#define PCI_VENDOR_ID_REDHAT             0x8085/g' include/hw/pci/pci.h

$SED -i 's/0x1af4/0x8086/g' hw/audio/hda-codec.c # QEMU_HDA_ID_VENDOR  0x1af4 =ich9-intel-hda
$SED -i 's/rev = 3/rev = 4/g' hw/i386/acpi-build.c # Most VMs use an older-style FADT of length 244  bytes (revision  3), cutting off before the Sleep Control/Status registers and Hypervisor ID
$SED -i 's/fadt.rev = 1/fadt.rev = 4/g' hw/i386/acpi-build.c # Most VMs use an older-style FADT of length 244  bytes (revision  3), cutting off before the Sleep Control/Status registers and Hypervisor ID
$SED -i 's/if (f->rev <= 4) {/if (f->rev <= 6) {\n\t\tbuild_append_gas_from_struct(tbl, \&f->sleep_ctl);\n\t\tbuild_append_gas_from_struct(tbl, \&f->sleep_sts);/g' hw/acpi/aml-build.c # # Most VMs use an older-style FADT of length 244  bytes (revision  3), cutting off before the Sleep Control/Status registers and Hypervisor ID
$SED -i 's/lat = 0xfff/lat = 0x1fff/g' hw/i386/acpi-build.c  # A value > 100 indicates the system does not support a C2/C3 state
$SED -i 's/"WAET"/"WWWT"/g' hw/i386/acpi-build.c # "WAET" is also present as a string inside the WAET table, so there's no need to check for its table signature
$SED -i 's/rev = 1/rev = 3/g' hw/i386/acpi-build.c # All upgrades require a minimum of 3.
$SED -i 's/dev = aml_device("PCI0");/aml_append(sb_scope, aml_name_decl("OSYS", aml_int(0x03E8)));\n\tAml *osi = aml_if(aml_equal(aml_call1("_OSI", aml_string("Windows 2012")), aml_int(1)));\n\taml_append(osi, aml_store(aml_int(0x07DC), aml_name("OSYS")));\n\taml_append(sb_scope, osi);\n\tosi = aml_if(aml_equal(aml_call1("_OSI",aml_string("Windows 2013")), aml_int(1)));\n\taml_append(osi, aml_store(aml_int(0x07DD), aml_name("OSYS")));\n\taml_append(sb_scope, osi);\n\taml_append(sb_scope, aml_name_decl("_TZ", aml_int(0x03E8)));\n\taml_append(sb_scope, aml_name_decl("_PTS", aml_int(0x03E8)));\n\tdev = aml_device("PCI0");/g' hw/i386/acpi-build.c # windows 2012 2013 _TZ_ _PTS dsdt

#$SED -i 's/0x0627/0x6666/g' hw/input/virtio-input-hid.c # 0x0627=QEMU tablet USB keyboard and mouse may have minor issues.
#$SED -i 's/0x0627/0x6666/g' hw/usb/dev-hid.c # 0x0627=QEMU tablet USB keyboard and mouse may have minor issues.

# BIOS Version suffix
$SED -i "s/prebuilt.qemu.org/${BRAND}/g" roms/Makefile

$SED -i "s/0x46f4/${BRAND_CRC16}/g" **/*.c
