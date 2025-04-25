const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const CompareFunction = @import("misc.zig").CompareFunction;

pub const SamplerBindingType = enum(u32) {
    @"undefined"  = 0x00000000,
    filtering     = 0x00000001,
    non_filtering = 0x00000002,
    comparison    = 0x00000003,
};

pub const SamplerBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    @"type": SamplerBindingType = SamplerBindingType.@"undefined",
};

pub const AddressMode = enum(u32) {
    repeat        = 0x00000000,
    mirror_repeat = 0x00000001,
    clamp_to_edge = 0x00000002,
};

pub const FilterMode = enum(u32) {
    nearest = 0x00000000,
    linear  = 0x00000001
};

pub const MipmapFilterMode = enum(u32) {
    nearest = 0x00000000,
    linear  = 0x00000001,
};

pub const SamplerDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    address_mode_u: AddressMode = AddressMode.clamp_to_edge,
    address_mode_v: AddressMode = AddressMode.clamp_to_edge,
    address_mode_w: AddressMode = AddressMode.clamp_to_edge,
    mag_filter: FilterMode = FilterMode.nearest,
    min_filter: FilterMode = FilterMode.nearest,
    mipmap_filter: MipmapFilterMode = MipmapFilterMode.nearest,
    lod_min_clamp: f32 = 0.0,
    lod_max_clamp: f32 = 32.0,
    compare: CompareFunction = CompareFunction.@"undefined",
    max_anisotropy: u16 = 1,
};

pub const SamplerProcs = struct {
    pub const SetLabel = *const fn(*Sampler, ?[*:0]const u8) callconv(.C) void;
    pub const AddRef = *const fn(*Sampler) callconv(.C) void;
    pub const Release = *const fn(*Sampler) callconv(.C) void;
};

extern fn wgpuSamplerSetLabel(sampler: *Sampler, label: ?[*:0]const u8) void;
extern fn wgpuSamplerAddRef(sampler: *Sampler) void;
extern fn wgpuSamplerRelease(sampler: *Sampler) void;

pub const Sampler = opaque {
    pub inline fn setLabel(self: *Sampler, label: ?[*:0]const u8) void {
        wgpuSamplerSetLabel(self, label);
    }
    pub inline fn reference(self: *Sampler) void {
        addRef(self);
    }
    pub inline fn addRef(self: *Sampler) void {
        wgpuSamplerAddRef(self);
    }
    pub inline fn release(self: *Sampler) void {
        wgpuSamplerRelease(self);
    }
};