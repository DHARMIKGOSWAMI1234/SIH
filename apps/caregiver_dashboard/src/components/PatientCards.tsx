import React from 'react';
import { User, UserPlus, CheckCircle2, ShieldCheck } from 'lucide-react';
import { PatientProfile } from '../api/client';

interface PatientCardsProps {
  patients: PatientProfile[];
  selectedPatientId: string;
  onSelectPatient: (patientId: string) => void;
  onConnectClick: () => void;
}

export const PatientCards: React.FC<PatientCardsProps> = ({
  patients,
  selectedPatientId,
  onSelectPatient,
  onConnectClick,
}) => {
  return (
    <div className="card mb-6" style={{ padding: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
        <div>
          <h2 style={{ fontSize: '16px', fontWeight: 700, margin: 0 }}>
            Monitored Patients ({patients.length})
          </h2>
          <p style={{ fontSize: '12px', color: 'var(--text-muted)', margin: '2px 0 0 0' }}>
            Select a patient to view real-time synchronized cognitive metrics and activity
          </p>
        </div>
        <button
          type="button"
          className="btn btn-primary"
          onClick={onConnectClick}
          style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', padding: '6px 14px' }}
        >
          <UserPlus size={15} />
          <span>+ Connect Patient</span>
        </button>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))',
          gap: '14px',
        }}
      >
        {patients.map((patient) => {
          const isSelected = patient.id === selectedPatientId;
          return (
            <div
              key={patient.id}
              onClick={() => onSelectPatient(patient.id)}
              style={{
                border: isSelected ? '2px solid #0e7490' : '1px solid var(--border-subtle)',
                background: isSelected ? 'rgba(14, 116, 144, 0.04)' : 'var(--bg-app)',
                borderRadius: '12px',
                padding: '14px',
                cursor: 'pointer',
                transition: 'all 0.15s ease',
                position: 'relative',
              }}
            >
              {isSelected && (
                <div
                  style={{
                    position: 'absolute',
                    top: '12px',
                    right: '12px',
                    color: '#0e7490',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px',
                    fontSize: '11px',
                    fontWeight: 600,
                  }}
                >
                  <CheckCircle2 size={14} />
                  <span>Active</span>
                </div>
              )}

              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
                <div
                  style={{
                    width: '38px',
                    height: '38px',
                    borderRadius: '50%',
                    background: isSelected ? '#0e7490' : 'var(--border-strong)',
                    color: '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontWeight: 700,
                    fontSize: '15px',
                  }}
                >
                  {patient.anonymous_alias ? patient.anonymous_alias.charAt(0).toUpperCase() : <User size={18} />}
                </div>
                <div>
                  <h4 style={{ fontSize: '14px', fontWeight: 700, margin: 0, color: 'var(--text-main)' }}>
                    {patient.anonymous_alias || 'Patient Record'}
                  </h4>
                  <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                    ID: {patient.id.length > 18 ? `${patient.id.slice(0, 18)}...` : patient.id}
                  </span>
                </div>
              </div>

              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  fontSize: '11px',
                  color: 'var(--text-muted)',
                  borderTop: '1px solid var(--border-subtle)',
                  paddingTop: '8px',
                  marginTop: '6px',
                }}
              >
                <span>Language: {patient.preferred_language?.toUpperCase() || 'EN'}</span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '3px', color: '#16a34a' }}>
                  <ShieldCheck size={12} />
                  <span>Connected</span>
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
