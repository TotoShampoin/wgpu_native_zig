const std = @import("std");

const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const FeatureName = _misc.FeatureName;
const StringView = _misc.StringView;

const _limits = @import("limits.zig");
const Limits = _limits.Limits;
const SupportedLimits = _limits.SupportedLimits;
const RequiredLimits = _limits.RequiredLimits;

const _bind_group = @import("bind_group.zig");
const BindGroupDescriptor = _bind_group.BindGroupDescriptor;
const BindGroup = _bind_group.BindGroup;
const BindGroupLayoutDescriptor = _bind_group.BindGroupLayoutDescriptor;
const BindGroupLayout = _bind_group.BindGroupLayout;

const _buffer = @import("buffer.zig");
const BufferDescriptor = _buffer.BufferDescriptor;
const Buffer = _buffer.Buffer;

const _queue = @import("queue.zig");
const QueueDescriptor = _queue.QueueDescriptor;
const Queue = _queue.Queue;
const SubmissionIndex = _queue.SubmissionIndex;

const _command_encoder = @import("command_encoder.zig");
const CommandEncoderDescriptor = _command_encoder.CommandEncoderDescriptor;
const CommandEncoder = _command_encoder.CommandEncoder;

const _pipeline = @import("pipeline.zig");
const ComputePipelineDescriptor = _pipeline.ComputePipelineDescriptor;
const ComputePipeline = _pipeline.ComputePipeline;
const DeviceCreateComputePipelineAsyncCallback = _pipeline.DeviceCreateComputePipelineAsyncCallback;
const PipelineLayoutDescriptor = _pipeline.PipelineLayoutDescriptor;
const PipelineLayout = _pipeline.PipelineLayout;
const RenderPipelineDescriptor = _pipeline.RenderPipelineDescriptor;
const RenderPipeline = _pipeline.RenderPipeline;
const DeviceCreateRenderPipelineAsyncCallback = _pipeline.DeviceCreateRenderPipelineAsyncCallback;

const _query_set = @import("query_set.zig");
const QuerySetDescriptor = _query_set.QuerySetDescriptor;
const QuerySet = _query_set.QuerySet;

const _render_bundle = @import("render_bundle.zig");
const RenderBundleEncoderDescriptor = _render_bundle.RenderBundleEncoderDescriptor;
const RenderBundleEncoder = _render_bundle.RenderBundleEncoder;

const _sampler = @import("sampler.zig");
const SamplerDescriptor = _sampler.SamplerDescriptor;
const Sampler = _sampler.Sampler;

const _shader = @import("shader.zig");
const ShaderModuleDescriptor = _shader.ShaderModuleDescriptor;
const ShaderModuleDescriptorSpirV =_shader.ShaderModuleDescriptorSpirV;
const ShaderModule = _shader.ShaderModule;

const _texture = @import("texture.zig");
const TextureDescriptor = _texture.TextureDescriptor;
const Texture = _texture.Texture;

pub const DeviceLostReason = enum(u32) {
    unknown    = 0x00000001,
    destroyed  = 0x00000002,
};

pub const DeviceLostCallback = *const fn(reason: DeviceLostReason, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;

pub const DeviceExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.device_extras,
    },
    trace_path: StringView,
};

pub fn defaultDeviceLostCallback(reason: DeviceLostReason, message: ?[*:0]const u8, _: ?*anyopaque) callconv(.C) void {
    std.log.err("Device lost: reason={s} message=\"{s}\"\n", .{ @tagName(reason), message orelse "" });
}

pub const ErrorType = enum(u32) {
    no_error      = 0x00000000,
    validation    = 0x00000001,
    out_of_memory = 0x00000002,
    internal      = 0x00000003,
    unknown       = 0x00000004,
    device_lost   = 0x00000005,
};

pub const ErrorCallback = *const fn(@"type": ErrorType, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;

pub const ErrorFilter = enum(u32) {
    validation    = 0x00000000,
    out_of_memory = 0x00000001,
    internal      = 0x00000002,
};

pub const UncapturedErrorCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    callback: ?ErrorCallback = null,
    userdata: ?*anyopaque = null,
};

pub const DeviceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    required_feature_count: usize = 0,
    required_features: ?[*]const FeatureName = null,
    required_limits: ?*const RequiredLimits,
    default_queue: QueueDescriptor = QueueDescriptor{},
    device_lost_callback: DeviceLostCallback = defaultDeviceLostCallback,
    device_lost_user_data: ?*anyopaque = null,
    uncaptured_error_callback_info: UncapturedErrorCallbackInfo = UncapturedErrorCallbackInfo{},

    pub inline fn withTracePath(self: DeviceDescriptor, trace_path: []const u8) DeviceDescriptor {
        var dd = self;
        dd.next_in_chain = @ptrCast(&DeviceExtras {
            .trace_path = StringView.fromSlice(trace_path),
        });
        return dd;
    }
};

pub const RequestDeviceStatus = enum(u32) {
    success  = 0x00000000,
    @"error" = 0x00000001,
    unknown  = 0x00000002,
};

// TODO: This probably belongs in adapter.zig
pub const AdapterRequestDeviceCallback = *const fn(status: RequestDeviceStatus, device: ?*Device, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const RequestDeviceResponse = struct {
    status: RequestDeviceStatus,
    message: ?[*:0]const u8,
    device: ?*Device,
};

// Generic function return type for wgpuGetProcAddress
// pub const Proc = *const fn() callconv(.C) void;

pub const DeviceProcs = struct {
    pub const CreateBindGroup = *const fn(*Device, *const BindGroupDescriptor) callconv(.C) ?*BindGroup;
    pub const CreateBindGroupLayout = *const fn(*Device, *const BindGroupLayoutDescriptor) callconv(.C) ?*BindGroupLayout;
    pub const CreateBuffer = *const fn(*Device, *const BufferDescriptor) callconv(.C) ?*Buffer;
    pub const CreateCommandEncoder = *const fn(*Device, *const CommandEncoderDescriptor) callconv(.C) ?*CommandEncoder;
    pub const CreateComputePipeline = *const fn(*Device, *const ComputePipelineDescriptor) callconv(.C) ?*ComputePipeline;
    pub const CreateComputePipelineAsync = *const fn(*Device, *const ComputePipelineDescriptor, DeviceCreateComputePipelineAsyncCallback, ?*anyopaque) callconv(.C) void;
    pub const CreatePipelineLayout = *const fn(*Device, *const PipelineLayoutDescriptor) callconv(.C) ?*PipelineLayout;
    pub const CreateQuerySet = *const fn(*Device, *const QuerySetDescriptor) callconv(.C) ?*QuerySet;
    pub const CreateRenderBundleEncoder = *const fn(*Device, *const RenderBundleEncoderDescriptor) callconv(.C) ?*RenderBundleEncoder;
    pub const CreateRenderPipeline = *const fn(*Device, *const RenderPipelineDescriptor) callconv(.C) ?*RenderPipeline;
    pub const CreateRenderPipelineAsync = *const fn(*Device, *const RenderPipelineDescriptor, DeviceCreateRenderPipelineAsyncCallback, ?*anyopaque) callconv(.C) void;
    pub const CreateSampler = *const fn(*Device, *const SamplerDescriptor) callconv(.C) ?*Sampler;
    pub const CreateShaderModule = *const fn(*Device, *const ShaderModuleDescriptor) callconv(.C) ?*ShaderModule;
    pub const CreateTexture = *const fn(*Device, *const TextureDescriptor) callconv(.C) ?*Texture;
    pub const Destroy = *const fn(*Device) callconv(.C) void;
    pub const EnumerateFeatures = *const fn(*Device, ?[*]FeatureName) callconv(.C) usize;
    pub const GetLimits = *const fn(*Device, *SupportedLimits) callconv(.C) WGPUBool;
    pub const GetQueue = *const fn(*Device) callconv(.C) ?*Queue;
    pub const HasFeature = *const fn(*Device, FeatureName) callconv(.C) WGPUBool;
    pub const PopErrorScope = *const fn(*Device, ErrorCallback, ?*anyopaque) callconv(.C) void;
    pub const PushErrorScope = *const fn(*Device, ErrorFilter) callconv(.C) void;
    pub const SetLabel = *const fn(*Device, ?[*:0]const u8) callconv(.C) void;
    pub const AddRef = *const fn(*Device) callconv(.C) void;
    pub const Release = *const fn(*Device) callconv(.C) void;

    // wgpu-native procs?
    // pub const Poll = *const fn(*Device, WGPUBool, ?*const SubmissionIndex) callconv(.C) WGPUBool;
    // pub const CreateShaderModuleSpirV = *const fn(*Device, *const ShaderModuleDescriptorSpirV) callconv(.C) ?*ShaderModule;
};

extern fn wgpuDeviceCreateBindGroup(device: *Device, descriptor: *const BindGroupDescriptor) ?*BindGroup;
extern fn wgpuDeviceCreateBindGroupLayout(device: *Device, descriptor: *const BindGroupLayoutDescriptor) ?*BindGroupLayout;
extern fn wgpuDeviceCreateBuffer(device: *Device, descriptor: *const BufferDescriptor) ?*Buffer;
extern fn wgpuDeviceCreateCommandEncoder(device: *Device, descriptor: *const CommandEncoderDescriptor) ?*CommandEncoder;
extern fn wgpuDeviceCreateComputePipeline(device: *Device, descriptor: *const ComputePipelineDescriptor) ?*ComputePipeline;
extern fn wgpuDeviceCreateComputePipelineAsync(device: *Device, descriptor: *const ComputePipelineDescriptor, callback: DeviceCreateComputePipelineAsyncCallback, userdata: ?*anyopaque) void;
extern fn wgpuDeviceCreatePipelineLayout(device: *Device, descriptor: *const PipelineLayoutDescriptor) ?*PipelineLayout;
extern fn wgpuDeviceCreateQuerySet(device: *Device, descriptor: *const QuerySetDescriptor) ?*QuerySet;
extern fn wgpuDeviceCreateRenderBundleEncoder(device: *Device, descriptor: *const RenderBundleEncoderDescriptor) ?*RenderBundleEncoder;
extern fn wgpuDeviceCreateRenderPipeline(device: *Device, descriptor: *const RenderPipelineDescriptor) ?*RenderPipeline;
extern fn wgpuDeviceCreateRenderPipelineAsync(device: *Device, descriptor: *const RenderPipelineDescriptor, callback: DeviceCreateRenderPipelineAsyncCallback, userdata: ?*anyopaque) void;
extern fn wgpuDeviceCreateSampler(device: *Device, descriptor: *const SamplerDescriptor) ?*Sampler;
extern fn wgpuDeviceCreateShaderModule(device: *Device, descriptor: *const ShaderModuleDescriptor) ?*ShaderModule;
extern fn wgpuDeviceCreateTexture(device: *Device, descriptor: *const TextureDescriptor) ?*Texture;
extern fn wgpuDeviceDestroy(device: *Device) void;
extern fn wgpuDeviceEnumerateFeatures(device: *Device, features: ?[*]FeatureName) usize;
extern fn wgpuDeviceGetLimits(device: *Device, limits: *SupportedLimits) WGPUBool;
extern fn wgpuDeviceGetQueue(device: *Device) ?*Queue;
extern fn wgpuDeviceHasFeature(device: *Device, feature: FeatureName) WGPUBool;
extern fn wgpuDevicePopErrorScope(device: *Device, callback: ErrorCallback, userdata: ?*anyopaque) void;
extern fn wgpuDevicePushErrorScope(device: *Device, filter: ErrorFilter) void;
extern fn wgpuDeviceSetLabel(device: *Device, label: ?[*:0]const u8) void;
extern fn wgpuDeviceAddRef(device: *Device) void;
extern fn wgpuDeviceRelease(device: *Device) void;

// wgpu-native
extern fn wgpuDevicePoll(device: *Device, wait: WGPUBool, submission_index: ?*const SubmissionIndex) WGPUBool;
extern fn wgpuDeviceCreateShaderModuleSpirV(device: *Device, descriptor: *const ShaderModuleDescriptorSpirV) ?*ShaderModule;

// Supposedly getProcAddress is a global function, but it doesn't seem like it should work without being tied to a Device?
// Could be it's one of those functions that's meant to be called with null the first time, TODO: look into that.
// 
// Regardless, apparently the reason it exists is because different devices have different drivers and therefore different procs,
// so you need to get the version of the proc that is meant for that particular device.
// 
// Although this function appears in webgpu.h, it is currently unimplemented in wgpu-native,
// (https://github.com/gfx-rs/wgpu-native/blob/trunk/src/unimplemented.rs)
// so I'm leaving it here in case it gets implemented eventually, but commented out until/unless that happens.
// extern fn wgpuGetProcAddress(device: *Device, proc_name: ?[*:0]const u8) ?Proc;

pub const Device = opaque {
    pub inline fn createBindGroup(self: *Device, descriptor: *const BindGroupDescriptor) ?*BindGroup {
        return wgpuDeviceCreateBindGroup(self, descriptor);
    }
    pub inline fn createBindGroupLayout(self: *Device, descriptor: *const BindGroupLayoutDescriptor) ?*BindGroupLayout {
        return wgpuDeviceCreateBindGroupLayout(self, descriptor);
    }
    pub inline fn createBuffer(self: *Device, descriptor: *const BufferDescriptor) ?*Buffer {
        return wgpuDeviceCreateBuffer(self, descriptor);
    }
    pub inline fn createCommandEncoder(self: *Device, descriptor: *const CommandEncoderDescriptor) ?*CommandEncoder {
        return wgpuDeviceCreateCommandEncoder(self, descriptor);
    }
    pub inline fn createComputePipeline(self: *Device, descriptor: *const ComputePipelineDescriptor) ?*ComputePipeline {
        return wgpuDeviceCreateComputePipeline(self, descriptor);
    }
    pub inline fn createComputePipelineAsync(self: *Device, descriptor: *const ComputePipelineDescriptor, callback: DeviceCreateComputePipelineAsyncCallback, userdata: ?*anyopaque) void {
        wgpuDeviceCreateComputePipelineAsync(self, descriptor, callback, userdata);
    }
    pub inline fn createPipelineLayout(self: *Device, descriptor: *const PipelineLayoutDescriptor) ?*PipelineLayout {
        return wgpuDeviceCreatePipelineLayout(self, descriptor);
    }
    pub inline fn createQuerySet(self: *Device, descriptor: *const QuerySetDescriptor) ?*QuerySet {
        return wgpuDeviceCreateQuerySet(self, descriptor);
    }
    pub inline fn createRenderBundleEncoder(self: *Device, descriptor: *const RenderBundleEncoderDescriptor) ?*RenderBundleEncoder {
        return wgpuDeviceCreateRenderBundleEncoder(self, descriptor);
    }
    pub inline fn createRenderPipeline(self: *Device, descriptor: *const RenderPipelineDescriptor) ?*RenderPipeline {
        return wgpuDeviceCreateRenderPipeline(self, descriptor);
    }
    pub inline fn createRenderPipelineAsync(self: *Device, descriptor: *const RenderPipelineDescriptor, callback: DeviceCreateRenderPipelineAsyncCallback, userdata: ?*anyopaque) void {
        wgpuDeviceCreateRenderPipelineAsync(self, descriptor, callback, userdata);
    }
    pub inline fn createSampler(self: *Device, descriptor: *const SamplerDescriptor) ?*Sampler {
        return wgpuDeviceCreateSampler(self, descriptor);
    }
    pub inline fn createShaderModule(self: *Device, descriptor: *const ShaderModuleDescriptor) ?*ShaderModule {
        return wgpuDeviceCreateShaderModule(self, descriptor);
    }
    pub inline fn createTexture(self: *Device, descriptor: *const TextureDescriptor) ?*Texture {
        return wgpuDeviceCreateTexture(self, descriptor);
    }
    pub inline fn destroy(self: *Device) void {
        wgpuDeviceDestroy(self);
    }
    pub inline fn enumerateFeatures(self: *Device, features: ?[*]FeatureName) usize {
        return wgpuDeviceEnumerateFeatures(self, features);
    }
    pub inline fn getLimits(self: *Device, limits: *SupportedLimits) WGPUBool {
        return wgpuDeviceGetLimits(self, limits);
    }
    pub inline fn getQueue(self: *Device) ?*Queue {
        return wgpuDeviceGetQueue(self);
    }
    pub inline fn hasFeature(self: *Device, feature: FeatureName) WGPUBool {
        return wgpuDeviceHasFeature(self, feature);
    }

    // TODO: Should popErrorScope have a non-callback version?
    pub inline fn popErrorScope(self: *Device, callback: ErrorCallback, userdata: ?*anyopaque) void {
        wgpuDevicePopErrorScope(self, callback, userdata);
    }
    pub inline fn pushErrorScope(self: *Device, filter: ErrorFilter) void {
        wgpuDevicePushErrorScope(self, filter);
    }
    pub inline fn setLabel(self: *Device, label: ?[*:0]const u8) void {
        wgpuDeviceSetLabel(self, label);
    }
    pub inline fn addRef(self: *Device) void {
        wgpuDeviceAddRef(self);
    }
    pub inline fn release(self: *Device) void {
        wgpuDeviceRelease(self);
    }

    // wgpu-native
    pub inline fn poll(self: *Device, wait: bool, wrapped_submission_index: ?*const SubmissionIndex) bool {
        return wgpuDevicePoll(self, @intFromBool(wait), wrapped_submission_index) != 0;
    }
    pub inline fn createShaderModuleSpirV(self: *Device, descriptor: *const ShaderModuleDescriptorSpirV) ?*ShaderModule {
        return wgpuDeviceCreateShaderModuleSpirV(self, descriptor);
    }

    // pub inline fn getProcAddress(self: *Device, proc_name: ?[*:0] const u8) ?Proc {
    //     return wgpuGetProcAddress(self, proc_name);
    // }
};

// TODO: Test methods of Device (as long as they can be tested headlessly: see https://eliemichel.github.io/LearnWebGPU/advanced-techniques/headless.html)