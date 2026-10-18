"""Render the actual MATLAB/Octave CSV output, without reimplementing physics."""
import argparse
import csv
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def plot(run_dir):
    with (run_dir / 'track_width_study.csv').open() as f:
        rows = list(csv.DictReader(f))
    rear = float(rows[0]['RearTrack_mm'])
    target_ay = float(rows[0]['TargetAy_g'])
    fig, axes = plt.subplots(2, 3, figsize=(16, 9), constrained_layout=True)
    panels = [
        ('DeltaLapTime_s', 'Lap time change [s]', 'Fixed supplied path'),
        ('LateralCapacity_g', 'Lateral capacity [g]', 'First axle or wheel-lift limit'),
        ('FrontRollFraction', 'Front roll fraction [-]', 'Controlled scenarios'),
        ('SkidpadLapTime_s', 'One timed lap [s]', 'Skidpad: ideal steering only'),
        ('TargetMinWheelLoad_N', 'Minimum wheel load [N]', f'Excel target: {target_ay:g} g'),
        ('EquivalentFrontSpring_NPerMm', 'Equivalent spring rate [N/mm]',
         'Sensitivity scenario; not a spring prescription'),
    ]
    scenarios = [('fixed_wheel_rate', 'Fixed wheel rate'),
                 ('fixed_axle_roll_stiffness', 'Fixed axle roll stiffness')]
    for ax, (field, ylabel, title) in zip(axes.flat, panels):
        for key, label in scenarios:
            selected = [row for row in rows if row['Scenario'] == key]
            ax.plot([float(r['FrontTrack_mm']) for r in selected],
                    [float(r[field]) for r in selected], '-o', ms=3, label=label)
        ax.set(xlabel=f'Front track [mm]; rear fixed at {rear:g} mm',
               ylabel=ylabel, title=title)
        ax.grid(alpha=.25)
        ax.legend(fontsize=8)
    axes[1, 1].axhline(0, color='red', linestyle='--', lw=1)
    fig.suptitle('Front-track screening | No transient yaw or actual rack model',
                 fontsize=15)
    target = run_dir / 'track_width_dashboard.png'
    fig.savefig(target, dpi=160)
    plt.close(fig)
    print(target)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('run_dir', type=Path)
    plot(parser.parse_args().run_dir)
