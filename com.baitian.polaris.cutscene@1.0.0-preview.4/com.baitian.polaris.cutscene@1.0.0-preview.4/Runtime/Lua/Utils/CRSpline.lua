module("Polaris.Cutscene",package.seeall)

CRSpline = class("CRSpline")

local Mathf = UnityEngine.Mathf

function CRSpline:ctor(vector3Array)
    self.pts = vector3Array
end

function CRSpline:Interp(t,notReturnVector3)
    if #self.pts < 2 then
        if notReturnVector3 then
            return 0,0,0
        end
        return Vector3(0,0,0)
    end
    if #self.pts < 3 then
        local x = self.pts[1].x + (self.pts[2].x - self.pts[1].x) * t
        local y = self.pts[1].y + (self.pts[2].y - self.pts[1].y) * t
        local z = self.pts[1].z + (self.pts[2].z - self.pts[1].z) * t
        if notReturnVector3 then
            return x,y,z
        end
        return Vector3(x,y,z)
    end
    if #self.pts < 4 then
        local d = 1 - t
        local x = d * d *self.pts[1].x + 2 *d * t *self.pts[2].x + t*t*self.pts[3].x
        local y = d * d *self.pts[1].y + 2 *d * t *self.pts[2].y + t*t*self.pts[3].y
        local z = d * d *self.pts[1].z + 2 *d * t *self.pts[2].z + t*t*self.pts[3].z
        if notReturnVector3 then
            return x,y,z
        end
        return Vector3(x,y,z)
    end
    local numSections = #self.pts - 3
    local currPt = math.min(math.floor(t * numSections), numSections - 1)
    local u = t * numSections - currPt
    local a = self.pts[currPt + 1]
    local b = self.pts[currPt + 2]
    local c = self.pts[currPt + 3]
    local d = self.pts[currPt + 4]

    local x = self:_InterpCalVecFunc(a.x,b.x,c.x,d.x,u)
    local y = self:_InterpCalVecFunc(a.y,b.y,c.y,d.y,u)
    local z = self:_InterpCalVecFunc(a.z,b.z,c.z,d.z,u)
    if notReturnVector3 then
        return x,y,z
    end
    return Vector3(x,y,z)
end

function CRSpline:_InterpCalVecFunc(a,b,c,d,u)
    return 0.5 * (
            (-a + 3 * b - 3 * c + d) * (u * u * u)
    + (2 * a - 5 * b + 4 * c - d) * (u * u)
    + (-a + c) * u
    + 2 * b
    )
end

function CRSpline:Velocity(t,notReturnVector3)
    local numSections = #self.pts - 3
    local currPt = math.min(math.floor(t * numSections), numSections - 1)
    local  u = t * numSections - currPt
    local a = self.pts[currPt + 1]
    local b = self.pts[currPt + 2]
    local c = self.pts[currPt + 3]
    local d = self.pts[currPt + 4]

    local x = self:_VelocityCalVecFunc(a.x,b.x,c.x,d.x,u)
    local y = self:_VelocityCalVecFunc(a.y,b.y,c.y,d.y,u)
    local z = self:_VelocityCalVecFunc(a.z,b.z,c.z,d.z,u)
    if notReturnVector3 then
        return x,y,z
    end
    return Vector3(x,y,z)
end

function CRSpline:_VelocityCalVecFunc(a,b,c,d,u)
    return 1.5 * (-a + 3 * b - 3 * c + d) * (u * u)
    + (2 * a - 5 * b + 4 * c - d) * u
    + 0.5 * c - 0.5 * a
end
