import React, { useState, useEffect } from 'react';
import {
  Brain,
  Plus,
  Star,
  Archive,
  Search,
  Filter,
  Image as ImageIcon,
  Mic,
  MapPin,
  Calendar,
  CheckCircle,
  Loader2,
} from 'lucide-react';
import { CaregiverApiClient, MemoryItem } from '../api/client';

export interface CaregiverMemory {
  id: string;
  title: string;
  personName?: string;
  relationship?: string;
  category: string;
  location?: string;
  year?: string;
  description: string;
  isFavorite: boolean;
  isArchived: boolean;
  hasAudio: boolean;
  hasImage: boolean;
}



const categories = [
  'All',
  'Family',
  'Friends',
  'Places',
  'Childhood',
  'Food',
  'Festivals',
  'Traditions',
  'Daily Life',
  'Objects',
];

interface MemoryManagerProps {
  patientId?: string;
  apiClient?: CaregiverApiClient;
}

export const MemoryManager: React.FC<MemoryManagerProps> = ({ patientId, apiClient }) => {
  const [subTab, setSubTab] = useState<'library' | 'add'>('library');
  const [memories, setMemories] = useState<CaregiverMemory[]>([]);
  const [isLoadingMemories, setIsLoadingMemories] = useState<boolean>(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All');

  // Load real memories from API if apiClient & patientId are available
  useEffect(() => {
    if (!apiClient || !patientId) {
      setIsLoadingMemories(false);
      return;
    }

    let isMounted = true;
    setIsLoadingMemories(true);
    apiClient
      .getMemories(patientId)
      .then((items: MemoryItem[]) => {
        if (!isMounted) return;
        if (items && items.length > 0) {
          const mapped: CaregiverMemory[] = items.map((m) => ({
            id: m.id || m.local_id,
            title: m.title,
            personName: m.person_name,
            relationship: m.relationship,
            category: m.category || 'General',
            location: m.location,
            year: m.event_date ? new Date(m.event_date).getFullYear().toString() : undefined,
            description: m.description,
            isFavorite: m.is_favorite ?? false,
            isArchived: m.is_archived ?? false,
            hasAudio: !!(m.audio_path || m.media_uri?.match(/\.(mp3|wav|m4a|aac)$/i)),
            hasImage: !!(m.image_path || m.media_uri?.match(/\.(jpg|jpeg|png|webp)$/i)),
          }));
          setMemories(mapped);
        } else {
          setMemories([]);
        }
      })
      .catch(() => {
        if (isMounted) setMemories([]);
      })
      .finally(() => {
        if (isMounted) setIsLoadingMemories(false);
      });

    return () => {
      isMounted = false;
    };
  }, [apiClient, patientId]);

  // New Memory Form State
  const [newTitle, setNewTitle] = useState('');
  const [newPerson, setNewPerson] = useState('');
  const [newRelationship, setNewRelationship] = useState('');
  const [newCategory, setNewCategory] = useState('Family');
  const [newLocation, setNewLocation] = useState('');
  const [newYear, setNewYear] = useState('');
  const [newDescription, setNewDescription] = useState('');
  const [newHasImage, setNewHasImage] = useState(false);
  const [newHasAudio, setNewHasAudio] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');

  const handleAddMemory = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim() || !newDescription.trim()) return;

    const newMem: CaregiverMemory = {
      id: `mem-${Date.now()}`,
      title: newTitle.trim(),
      personName: newPerson.trim() || undefined,
      relationship: newRelationship.trim() || undefined,
      category: newCategory,
      location: newLocation.trim() || undefined,
      year: newYear.trim() || undefined,
      description: newDescription.trim(),
      isFavorite: false,
      isArchived: false,
      hasAudio: newHasAudio,
      hasImage: newHasImage,
    };

    setMemories([newMem, ...memories]);
    setSuccessMessage('Memory created successfully.');
    setNewTitle('');
    setNewPerson('');
    setNewRelationship('');
    setNewLocation('');
    setNewYear('');
    setNewDescription('');
    setNewHasImage(false);
    setNewHasAudio(false);
    setTimeout(() => {
      setSuccessMessage('');
      setSubTab('library');
    }, 1500);
  };

  const toggleFavorite = (id: string) => {
    setMemories(
      memories.map((m) => (m.id === id ? { ...m, isFavorite: !m.isFavorite } : m))
    );
  };

  const toggleArchive = (id: string) => {
    setMemories(
      memories.map((m) => (m.id === id ? { ...m, isArchived: !m.isArchived } : m))
    );
  };

  const filteredMemories = memories.filter((m) => {
    if (m.isArchived) return false;
    if (categoryFilter !== 'All' && m.category.toLowerCase() !== categoryFilter.toLowerCase()) return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      return (
        m.title.toLowerCase().includes(q) ||
        m.description.toLowerCase().includes(q) ||
        (m.personName?.toLowerCase().includes(q) ?? false) ||
        (m.relationship?.toLowerCase().includes(q) ?? false) ||
        (m.location?.toLowerCase().includes(q) ?? false)
      );
    }
    return true;
  });

  return (
    <div className="tab-pane">
      {/* Header */}
      <div className="page-header-flex">
        <div>
          <h1 className="page-title">Memory</h1>
          <p className="page-subtitle">
            Familiar memories and culturally meaningful moments.
          </p>
        </div>
      </div>

      {/* Sub navigation */}
      <div className="flex gap-2 border-b border-border pb-3 mb-6 overflow-x-auto">
        <button
          className={`px-4 py-2 rounded-lg font-medium text-sm transition-colors ${
            subTab === 'library' ? 'bg-sage text-white' : 'bg-card text-muted hover:text-foreground'
          }`}
          onClick={() => setSubTab('library')}
        >
          Memory Library ({memories.filter((m) => !m.isArchived).length})
        </button>
        <button
          className={`px-4 py-2 rounded-lg font-medium text-sm flex items-center gap-1.5 transition-colors ${
            subTab === 'add' ? 'bg-sage text-white' : 'bg-card text-muted hover:text-foreground'
          }`}
          onClick={() => setSubTab('add')}
        >
          <Plus size={16} /> Add Memory
        </button>
      </div>

      {/* Subtab: Library */}
      {subTab === 'library' && (
        <>
          {/* Controls Bar */}
          <div className="flex flex-col sm:flex-row gap-3 mb-6">
            <div className="relative flex-1">
              <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
              <input
                type="text"
                placeholder="Search memories by name, place, relationship..."
                className="input-field pl-10 w-full"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
            <div className="flex items-center gap-2">
              <Filter size={18} className="text-muted" />
              <select
                className="input-field"
                value={categoryFilter}
                onChange={(e) => setCategoryFilter(e.target.value)}
              >
                {categories.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Memory Cards Grid */}
          {isLoadingMemories ? (
            <div className="card text-center py-12">
              <Loader2 size={32} className="mx-auto text-sage mb-3 animate-spin" style={{ animation: 'spin 1s linear infinite' }} />
              <p className="text-muted" style={{ margin: 0, fontSize: '14px' }}>Loading patient memories...</p>
            </div>
          ) : filteredMemories.length === 0 ? (
            <div className="card text-center py-12">
              <Brain size={48} className="mx-auto text-muted mb-3" />
              <h3 className="section-title">No memories found</h3>
              <p className="section-subtitle mt-1">
                Add a new personal memory to begin building the patient reminiscence bank.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredMemories.map((m) => (
                <div key={m.id} className="card flex flex-col justify-between">
                  <div>
                    <div className="flex justify-between items-start mb-3">
                      <span className="badge-pill text-xs">{m.category}</span>
                      <div className="flex items-center gap-1">
                        <button
                          onClick={() => toggleFavorite(m.id)}
                          className="p-1 rounded hover:bg-card text-muted hover:text-amber-500"
                          title="Toggle Favorite"
                        >
                          <Star
                            size={18}
                            className={m.isFavorite ? 'fill-amber-400 text-amber-500' : ''}
                          />
                        </button>
                        <button
                          onClick={() => toggleArchive(m.id)}
                          className="p-1 rounded hover:bg-card text-muted hover:text-red-500"
                          title="Archive Memory"
                        >
                          <Archive size={18} />
                        </button>
                      </div>
                    </div>

                    <h4 className="font-semibold text-lg text-foreground mb-1">{m.title}</h4>

                    {m.personName && (
                      <p className="text-sm font-medium text-sage mb-2">
                        {m.personName} {m.relationship ? `(${m.relationship})` : ''}
                      </p>
                    )}

                    <p className="text-sm text-muted line-clamp-3 mb-4">{m.description}</p>
                  </div>

                  <div className="pt-3 border-t border-border flex items-center justify-between text-xs text-muted">
                    <div className="flex items-center gap-2">
                      {m.location && (
                        <span className="flex items-center gap-1">
                          <MapPin size={12} /> {m.location}
                        </span>
                      )}
                      {m.year && (
                        <span className="flex items-center gap-1">
                          <Calendar size={12} /> {m.year}
                        </span>
                      )}
                    </div>
                    <div className="flex items-center gap-2">
                      {m.hasImage && (
                        <span title="Photo Attached">
                          <ImageIcon size={14} />
                        </span>
                      )}
                      {m.hasAudio && (
                        <span title="Voice Note Attached">
                          <Mic size={14} />
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {/* Subtab: Add Memory */}
      {subTab === 'add' && (
        <div className="card max-w-2xl">
          <h3 className="section-title mb-2">Add New Personal Memory</h3>
          <p className="section-subtitle mb-6">
            Create a reminiscence card for familiar cognitive exercises.
          </p>

          {successMessage && (
            <div className="p-4 mb-6 rounded-lg bg-emerald-50 text-emerald-800 border border-emerald-200 flex items-center gap-2">
              <CheckCircle size={18} /> {successMessage}
            </div>
          )}

          <form onSubmit={handleAddMemory} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Memory Title *</label>
              <input
                type="text"
                required
                placeholder="e.g., Afternoon Tea on the Veranda"
                className="input-field w-full"
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Person Name (Optional)</label>
                <input
                  type="text"
                  placeholder="e.g., Rahul"
                  className="input-field w-full"
                  value={newPerson}
                  onChange={(e) => setNewPerson(e.target.value)}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Relationship (Optional)</label>
                <input
                  type="text"
                  placeholder="e.g., Grandson"
                  className="input-field w-full"
                  value={newRelationship}
                  onChange={(e) => setNewRelationship(e.target.value)}
                />
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">Category</label>
                <select
                  className="input-field w-full"
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value)}
                >
                  {categories.filter((c) => c !== 'All').map((c) => (
                    <option key={c} value={c}>
                      {c}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Location</label>
                <input
                  type="text"
                  placeholder="e.g., Majuli, Assam"
                  className="input-field w-full"
                  value={newLocation}
                  onChange={(e) => setNewLocation(e.target.value)}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Year</label>
                <input
                  type="text"
                  placeholder="e.g., 1985"
                  className="input-field w-full"
                  value={newYear}
                  onChange={(e) => setNewYear(e.target.value)}
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Story / Description *</label>
              <textarea
                required
                rows={3}
                placeholder="Share a warm description or memory note..."
                className="input-field w-full"
                value={newDescription}
                onChange={(e) => setNewDescription(e.target.value)}
              />
            </div>

            {/* Media Toggles */}
            <div className="flex gap-4 pt-2">
              <label className="flex items-center gap-2 cursor-pointer text-sm">
                <input
                  type="checkbox"
                  checked={newHasImage}
                  onChange={(e) => setNewHasImage(e.target.checked)}
                />
                <ImageIcon size={16} /> Attach Local Photo
              </label>
              <label className="flex items-center gap-2 cursor-pointer text-sm">
                <input
                  type="checkbox"
                  checked={newHasAudio}
                  onChange={(e) => setNewHasAudio(e.target.checked)}
                />
                <Mic size={16} /> Attach Local Voice Note
              </label>
            </div>

            <div className="pt-4 flex gap-3">
              <button type="submit" className="btn-primary">
                Save Memory
              </button>
              <button
                type="button"
                className="btn-secondary"
                onClick={() => setSubTab('library')}
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};
