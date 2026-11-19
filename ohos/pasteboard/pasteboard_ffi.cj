/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// The Cangjie API is in Beta. For details on its capabilities and limitations, please refer to the README file.

package ohos.pasteboard

import ohos.business_exception.BusinessException
import ohos.ffi.{CArrString, RetDataBool, RetDataCArrString, RetDataCString, RetDataI64, RetDataUI, safeMalloc}
import std.collection.HashMap

foreign {
    func FfiOHOSCreateStringPasteData(mimeType: CString, value: CString): RetDataI64
    func FfiOHOSCreatePixelMapPasteData(mimeType: CString, pixelMapId: Int64): RetDataI64
    func FfiOHOSCreateArrayBufPasteData(mimeType: CString, buffPtr: CPointer<UInt8>, bufferSize: Int64): RetDataI64
    func FfiOHOSCreateStringPasteDataRecord(
        mimeType: CString, value: CString, retPtr: CPointer<CPasteDataRecord>): RetDataI64
    func FfiOHOSCreatePixelMapPasteDataRecord(
        mimeType: CString, pixelMapId: Int64, retPtr: CPointer<CPasteDataRecord>): RetDataI64
    func FfiOHOSCreateArrayBufPasteDataRecord(
        mimeType: CString, buffPtr: CPointer<UInt8>, bufferSize: Int64,
        retPtr: CPointer<CPasteDataRecord>): RetDataI64
    func FfiOHOSCreateMultiTypePasteData(entries: CPointer<CArrPasteDataEntry>): RetDataI64

    func FfiOHOSPasteDataGetPrimaryText(id: Int64): RetDataCString
    func FfiOHOSPasteDataGetPrimaryHtml(id: Int64): RetDataCString
    func FfiOHOSPasteDataGetPrimaryUri(id: Int64): RetDataCString
    func FfiOHOSPasteDataGetPrimaryPixelMap(id: Int64): RetDataI64
    func FfiOHOSPasteDataGetPrimaryMimeType(id: Int64): RetDataCString
    func FfiOHOSPasteDataGetProperty(id: Int64, retPtr: CPointer<CPasteDataProperty>): Int32
    func FfiOHOSPasteDataSetProperty(
        id: Int64, mimeTypes: CArrString, tag: CString, timestamp: Int64, localOnly: Bool,
        shareOption: Int32): Int32
    func FfiOHOSPasteDataGetTag(id: Int64): RetDataCString
    func FfiOHOSPasteDataHasType(id: Int64, mimeType: CString): RetDataBool
    func FfiOHOSPasteDataAddRecord(id: Int64, recordId: Int64): Int32
    func FfiOHOSPasteDataAddMimeTypeRecord(id: Int64, mimeType: CString, value: CString): Int32
    func FfiOHOSPasteDataAddPixelMapRecord(id: Int64, mimeType: CString, pixelMapId: Int64): Int32
    func FfiOHOSPasteDataAddArrayRecord(
        id: Int64, mimeType: CString, buffPtr: CPointer<UInt8>, bufferSize: Int64): Int32
    func FfiOHOSPasteDataGetMimeTypes(id: Int64): RetDataCArrString
    func FfiOHOSPasteDataGetRecord(id: Int64, index: Int32, retPtr: CPointer<CPasteDataRecord>): RetDataI64
    func FfiOHOSPasteDataGetRecordV2(id: Int64, index: Int32, retPtr: CPointer<CPasteDataRecord>): RetDataI64
    func FfiOHOSPasteDataGetRecordCount(id: Int64): RetDataUI
    func FfiOHOSPasteDataRemoveRecord(id: Int64, index: Int32): Int32
    func FfiOHOSPasteDataReplaceRecord(id: Int64, recordId: Int64, index: Int32): Int32

    func FfiOHOSGetSystemPasteboard(): RetDataI64
    func FfiOHOSGetSystemPasteboardV2(): RetDataI64
    func FfiOHOSSystemPasteboardSetData(id: Int64, pasteDataId: Int64): Int32
    func FfiOHOSSystemPasteboardGetData(id: Int64): RetDataI64
    func FfiOHOSSystemPasteboardHasData(id: Int64): RetDataBool
    func FfiOHOSSystemPasteboardClearData(id: Int64): Unit
    func FfiOHOSSystemPasteboardIsRemoteData(id: Int64): RetDataBool
    func FfiOHOSSystemPasteboardHasDataType(id: Int64, mimeType: CString): RetDataBool
    func FfiOHOSSystemPasteboardGetDataSource(id: Int64): RetDataCString
    func FfiOHOSSystemPasteboardSetDataV2(id: Int64, pasteDataId: Int64): Int32
    func FfiOHOSSystemPasteboardGetDataV2(id: Int64): RetDataI64
    func FfiOHOSSystemPasteboardIsRemoteDataV2(id: Int64): RetDataBool
    func FfiOHOSSystemPasteboardHasDataTypeV2(id: Int64, mimeType: CString): RetDataBool
    func FfiOHOSSystemPasteboardGetDataSourceV2(id: Int64): RetDataCString

    func FfiOHOSFreeCString(value: CString): Unit
    func FfiOHOSFreeCArrString(value: CPointer<CArrString>): Unit
    func FfiOHOSFreePasteDataProperty(property: CPointer<CPasteDataProperty>): Unit
    func FfiOHOSFreePasteDataRecord(record: CPointer<CPasteDataRecord>): Unit
}

@C
struct CPasteDataProperty {
    var mimeTypes: CArrString = CArrString(CPointer<CString>(), 0)
    var tag: CString = CString(CPointer<UInt8>())
    var timestamp: Int64 = 0
    var localOnly: Bool = false
    var shareOption: Int32 = 1
}

@C
struct CPasteDataRecord {
    var htmlText: CString = CString(CPointer<UInt8>())
    var mimeType: CString = CString(CPointer<UInt8>())
    var plainText: CString = CString(CPointer<UInt8>())
    var uri: CString = CString(CPointer<UInt8>())
    var pixelMap: Int64 = 0
}

@C
struct CPasteDataEntry {
    var valueType: Int8 = 0
    var mimeType: CString = CString(CPointer<UInt8>())
    var value: CPointer<Unit> = CPointer<Unit>()
    var size: Int64 = 0

    init(mimeType: String, data: PasteDataValueType) {
        this.mimeType = unsafe { LibC.mallocCString(mimeType) }
        unsafe {
            try {
                match (data) {
                    case StringValue(text) =>
                        valueType = 0
                        let cValue = LibC.mallocCString(text)
                        value = CPointer<Unit>(cValue.getChars())
                    case PixelMapValue(pixelMap) =>
                        valueType = 1
                        let idPtr = safeMalloc<Int64>()
                        idPtr.write(pixelMap.getID())
                        value = CPointer<Unit>(idPtr)
                    case ArrayBufferValue(buffer) =>
                        valueType = 2
                        let count = if (buffer.isEmpty()) { 1 } else { buffer.size }
                        let bufferPtr = safeMalloc<UInt8>(count: count)
                        for (i in 0..buffer.size) {
                            bufferPtr.write(i, buffer[i])
                        }
                        value = CPointer<Unit>(bufferPtr)
                        size = buffer.size
                    case _ => throw BusinessException(401, "Parameter error. Parameter verification failed.")
                }
            } catch (e: Exception) {
                LibC.free(this.mimeType)
                throw e
            }
        }
    }

    func free(): Unit {
        unsafe {
            LibC.free(mimeType)
            if (value.isNull()) {
                return
            }
            match (valueType) {
                case 0 => LibC.free(CPointer<UInt8>(value))
                case 1 => LibC.free(CPointer<Int64>(value))
                case 2 => LibC.free(CPointer<UInt8>(value))
                case _ => ()
            }
        }
    }
}

@C
struct CArrPasteDataEntry {
    var head: CPointer<CPasteDataEntry> = CPointer<CPasteDataEntry>()
    var size: Int64 = 0

    init(data: HashMap<String, PasteDataValueType>) {
        size = data.size
        if (size == 0) {
            return
        }
        unsafe {
            head = safeMalloc<CPasteDataEntry>(count: size)
            var index = 0
            try {
                for ((mimeType, value) in data) {
                    head.write(index, CPasteDataEntry(mimeType, value))
                    index++
                }
            } catch (e: Exception) {
                for (i in 0..index) {
                    head.read(i).free()
                }
                LibC.free(head)
                throw e
            }
        }
    }

    func free(): Unit {
        if (head.isNull()) {
            return
        }
        unsafe {
            for (i in 0..size) {
                head.read(i).free()
            }
            LibC.free(head)
        }
    }
}
